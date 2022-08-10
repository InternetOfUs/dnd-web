use actix_files as fs;
use actix_session::{storage::CookieSessionStore, Session, SessionMiddleware};
use actix_web::http::header::ContentType;
use actix_web::web::Data;
use actix_web::{get, middleware::Logger, post, web, App, HttpResponse, HttpServer, Responder};
use actix_web::{rt as actix_rt, HttpRequest};
use dotenvy::dotenv;
use flume::{self, Sender};
use log::{self, info, warn};
use regex::Regex;
use reqwest::{self, StatusCode};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fmt::{self};
use std::{env, vec};
/// All possible errors
#[derive(Deserialize, Serialize, Debug)]
enum DnDError {
    /// Unable to perform the operations (bad auth?)
    OperationNotPermitted,
    /// Timeout when connecting to Profile Manager
    ProfileManagerTimeout,
    /// User not found
    ProfileManagerUserNotFound,
    /// Unable to create a norm
    ProfileManagerUnableToCreateNorm,
    /// Unable to edit a norm
    ProfileManagerUnableToEdit,
    /// Unable to delete a norm
    ProfileManagerUnableToDeleteNorm,
    /// Error 500 from the Profile Manager
    ProfileManager500,
    /// For unknown errors
    UnknownError,
}
#[derive(Deserialize, Serialize, Debug)]
enum Content {
    Entries(Vec<DnDEntry>),
}

#[derive(Deserialize, Serialize, Debug)]
struct Message {
    error: Option<DnDError>,
    content: Option<Content>,
}

impl fmt::Display for Message {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "error {:?} - content {:?}", self.error, self.content)
    }
}
/// Action on the Entry
#[derive(Deserialize, Serialize)]
enum EntryAction {
    Create,
    Delete,
    Update,
}

/// User action, mean for recording
#[derive(Deserialize, Serialize)]
struct UserAction {
    /// userid of the user
    userid: String,
    /// entry that are touched
    entry: DnDEntry,
    /// performed action
    action: EntryAction,
    /// status of the action
    status: String,
}

/// One DnDEntry of the user (TODO change name)
#[derive(Deserialize, Serialize, Clone, Debug)]
struct DnDEntry {
    /// Week of the day, 1 Monday .. 7 Sunday
    weekday: i32,
    /// From when DnD
    time_from: String,
    /// To
    time_to: String,
    /// Where the user is usually
    label: String,
    /// Previous entry
    old: Option<Box<DnDEntry>>,
}

impl DnDEntry {
    /// Transform the `DnDEntry` to a `Norm`
    /// Returns the norm
    fn to_norm(&self) -> Norm {
        let mut norm = Norm {
            description: None,
            whenever: format!(
                "is_now_between_times('{}','{}') and is_now_one_of_week_days([{}])",
                self.time_from, self.time_to, self.weekday
            ),
            thenceforth: "not(send_user_message(_,_))".to_string(),
            ontology: None,
            priority: None,
        };
        norm.description = Some(format!("DND_{}_{}", norm.compute_id(), self.label));
        norm
    }
}

impl fmt::Display for DnDEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} - {} - {} - {}",
            self.weekday, self.time_from, self.time_to, self.label
        )
    }
}
#[derive(Deserialize, Serialize)]
struct PartialProfileForPatch {
    norms: Vec<Norm>,
}

/// Norm associated with a user
#[derive(Deserialize, Clone)]
struct DnDEntryWitUser {
    /// User id - owner of the norm
    userid: String,
    /// The norm
    entry: DnDEntry,
}

impl fmt::Display for DnDEntryWitUser {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} - {}", self.userid, self.entry)
    }
}

/// Represent a norm
#[derive(Deserialize, Serialize, Clone)]
struct Norm {
    /// Description of the norm, with a keyword to identify the "class"
    description: Option<String>,
    /// When the norm is effective
    whenever: String,
    /// What to do
    thenceforth: String,
    /// Ontology, mostly null
    ontology: Option<String>,
    /// Priority, mostly null
    priority: Option<i32>,
}

impl Norm {
    /// Returns the compute id of this [`Norm`]. Use sh256 to create it
    fn compute_id(&self) -> String {
        let mut hasher = Sha256::new();
        let norm_str = format!("{} - {}", self.whenever, self.thenceforth);
        hasher.update(norm_str);
        let hash = hasher.finalize();
        format!("{:X}", hash)
    }

    /// try to create an DnDEntry from a norm
    ///
    /// Not all norms are for DnD, so we don't touch
    /// unralted noms, only the ones starting by *DND_*
    ///
    /// Return Some(DndEntry) if success, None otherwise
    fn to_dnd_entry(&self) -> Option<DnDEntry> {
        if let Some(desc) = self.description.clone() {
            if desc.contains("DND_") {
                let re_whenever = Regex::new(r"is_now_between_times\('(([01][0-9]|2[0-3]):([0-5][0-9]))','(([01][0-9]|2[0-3]):([0-5][0-9]))'\) and is_now_one_of_week_days\(\[(\d)\]\)").unwrap();
                let caps = re_whenever.captures(&self.whenever).unwrap();

                let time_from = caps.get(1).map_or("", |m| m.as_str());
                let time_to = caps.get(4).map_or("", |m| m.as_str());
                let weekday = caps
                    .get(7)
                    .map_or(1, |m| m.as_str().parse::<i32>().unwrap());

                let re_description = Regex::new(r"DND_(\w+)_(.*)").unwrap();
                let caps = re_description.captures(&desc).unwrap();
                let _norm_id = caps.get(1).map_or("", |m| m.as_str());
                let norm_label = caps.get(2).map_or("", |m| m.as_str());
                return Some(DnDEntry {
                    weekday: weekday,
                    time_from: time_from.to_string(),
                    time_to: time_to.to_string(),
                    label: norm_label.to_string(),
                    old: None,
                });
            }
        }
        None
    }
}

impl fmt::Display for Norm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "\n\tdesc: {}\n\twhen: {}\n\tthen: {}",
            self.description.as_ref().unwrap_or(&String::new()),
            self.whenever,
            self.thenceforth
        )
    }
}

/// Struct for callback code parameter from oauth2
#[derive(Deserialize)]
struct Code {
    /// code from oauth2 server
    code: String,
}

/// Request data for a token
#[derive(Serialize, Deserialize)]
struct OAuth2TokenRequest {
    grant_type: String,
    client_id: String,
    client_secret: String,
    code: String,
}

/// Response data for a token
#[derive(Deserialize)]
struct OAuth2TokenResponse {
    refresh_token: String,
    token_type: String,
    access_token: String,
    expires_in: i32,
}

/// Response for token info
#[derive(Deserialize)]
struct OAuth2TokenInfo {
    profileId: String,
    appId: String,
    scopes: Vec<String>,
}

async fn get_userid_from_token(token: &String) -> Option<String> {
    let secret = env::var("WENET_SECRET").unwrap_or_default();
    let url = "https://internetofus.u-hopper.com/prod/api/service/token";
    let client = reqwest::Client::new();
    let mut userid: Option<String> = None;
    let res = client
        .get(url)
        .header("x-wenet-component-apikey", secret)
        .header("Authorization", format!("bearer {token}"))
        .header("Accept", "application/json")
        .send()
        .await;
    if let Ok(res) = res {
        let content: Result<OAuth2TokenInfo, _> = res.json().await;
        if let Ok(content) = content {
            userid = Some(content.profileId);
            info!("profileId was retrieved successfuly");
        } else {
            warn!("issue when trying to get profileId from OAuth2TokenInfo");
        }
    } else {
        warn!("issue while requesting the profileId");
    }
    userid
}

/// Get all norms for user `userid`
///
/// # Arguments
///
/// * `norms` mutable vector who will be filled with norms
/// * `userid` the user id
///
/// Returns Statuscode or reqwest error. The status code can say something wrong happened too
async fn get_all_norms(userid: &str, norms: &mut Vec<Norm>) -> Result<StatusCode, reqwest::Error> {
    let secret = env::var("WENET_SECRET").unwrap_or_default();
    let url = env::var("WENET_BASE_URL")
        .unwrap_or_else(|_| "https://wenet.u-hopper.com/dev/".to_string());
    let url = format!("{url}profile_manager/profiles/{userid}/norms");
    let client = reqwest::Client::new();
    let res = client
        .get(&url)
        .header("x-wenet-component-apikey", secret)
        .header("Authorization", "test:wenet")
        .header("Accept", "application/json")
        .send()
        .await?;
    let status = res.status();
    let received_norms: Vec<Option<Norm>> = res.json().await.unwrap_or_default();
    let received_norms_len = received_norms.len();
    for norm in received_norms {
        if let Some(norm) = norm {
            norms.push(norm);
        }
    }
    info!("asked norms for user {}", userid);
    info!("answer {} norm(s)", received_norms_len);

    Ok(status)
}

async fn delete_a_norm(userid: &str, entry: &DnDEntry) -> Result<StatusCode, reqwest::Error> {
    let mut norms: Vec<Norm> = vec![];
    let norm_to_delete = entry.to_norm();
    let id_to_delete = norm_to_delete.compute_id();
    let mut new_norms: Vec<Norm> = vec![];
    let s_get = get_all_norms(userid, &mut norms).await?;
    for norm in &norms {
        if let Some(_dnd_entry) = norm.to_dnd_entry() {
            if norm.compute_id() != id_to_delete {
                new_norms.push((*norm).clone());
            }
        } else {
            new_norms.push((*norm).clone());
        }
    }
    let old_len = norms.len();
    let new_len = new_norms.len();
    let partial_profile = PartialProfileForPatch { norms: new_norms };
    let secret = env::var("WENET_SECRET").unwrap_or_default();
    let url = env::var("WENET_BASE_URL")
        .unwrap_or_else(|_| "https://wenet.u-hopper.com/dev/".to_string());
    let url = format!("{url}profile_manager/profiles/{userid}");
    let client = reqwest::Client::new();
    let res = client
        .patch(&url)
        .header("x-wenet-component-apikey", secret)
        .header("Authorization", "test:wenet")
        .header("Content-Type", "application/json")
        .header("Accept", "application/json")
        .json(&partial_profile)
        .send()
        .await?;
    let status = res.status();
    let answer = res.text().await.unwrap_or("no answer".to_string());
    info!("patched sended, from {} to {}", old_len, new_len);
    info!("answer {}", answer);

    Ok(s_get)
}

/// Send one norm to the Profile Manager.
///
/// # Arguments
///
/// * `norm` The norm to send
/// * `userid` The userid of the user
///
/// Returns Statuscode or reqwest error. The status code can say something wrong happened too
async fn send_one_norm(norm: &Norm, userid: &str) -> Result<StatusCode, reqwest::Error> {
    let secret = env::var("WENET_SECRET").unwrap_or_default();
    let url = env::var("WENET_BASE_URL")
        .unwrap_or_else(|_| "https://wenet.u-hopper.com/dev/".to_string());
    let url = format!("{url}profile_manager/profiles/{userid}/norms");
    let client = reqwest::Client::new();
    let res = client
        .post(&url)
        .header("x-wenet-component-apikey", secret)
        .header("Authorization", "test:wenet")
        .header("Content-Type", "application/json")
        .header("Accept", "application/json")
        .json(&norm)
        .send()
        .await?;
    let status = res.status();
    let answer = res.text().await.unwrap_or("no answer".to_string());
    info!("sended at {} the norm {}", url, norm);
    info!("answer {}", answer);

    Ok(status)
}

async fn save_user_action(user_action: UserAction) -> bool {
    if let Ok(url) = env::var("FIREBASE_URL") {
        let url = format!("{url}action_list.json");
        let client = reqwest::Client::new();
        let res = client
            .post(&url)
            .header("Content-Type", "application/json")
            .header("Accept", "application/json")
            .json(&user_action)
            .send()
            .await;
        if let Ok(_) = res {
            true
        } else {
            false
        }
    } else {
        false
    }
}

#[post("/delete_entry")]
async fn delete_entry(dnd_entry: web::Json<DnDEntryWitUser>) -> impl Responder {
    let entry = &dnd_entry.entry;
    let userid = &dnd_entry.userid;
    let res = delete_a_norm(userid, entry).await;
    let res = match res {
        Ok(status) => {
            if status.is_success() {
                Message {
                    content: None,
                    error: None,
                }
            } else {
                match status {
                    StatusCode::INTERNAL_SERVER_ERROR => Message {
                        error: Some(DnDError::ProfileManager500),
                        content: None,
                    },
                    StatusCode::NOT_FOUND => Message {
                        error: Some(DnDError::ProfileManagerUserNotFound),
                        content: None,
                    },
                    StatusCode::GATEWAY_TIMEOUT => Message {
                        error: Some(DnDError::ProfileManagerTimeout),
                        content: None,
                    },
                    _ => Message {
                        error: Some(DnDError::ProfileManagerUnableToCreateNorm),
                        content: None,
                    },
                }
            }
        }
        Err(e) => {
            log::error!("{:?}", e);
            Message {
                error: Some(DnDError::ProfileManagerTimeout),
                content: None,
            }
        }
    };
    let user_action = UserAction {
        entry: (*entry).clone(),
        action: EntryAction::Delete,
        userid: dnd_entry.userid.clone(),
        status: format!("{:?}", res),
    };
    save_user_action(user_action).await;
    web::Json(res)
}

/// add DnDEntry - create a norm
///
/// # Arguments
///
/// * `entry` - DnDEntry in json
#[post("/add_entry")]
async fn add_entry(dnd_entry: web::Json<DnDEntryWitUser>) -> impl Responder {
    let entry = &dnd_entry.entry;
    println!("received {}", entry);
    if let Some(old) = entry.old.clone() {
        let res = delete_a_norm(&dnd_entry.userid, &old).await;
        let previous_msg = match res {
            Ok(status) => {
                if status.is_success() {
                    Message {
                        content: None,
                        error: None,
                    }
                } else {
                    match status {
                        StatusCode::INTERNAL_SERVER_ERROR => Message {
                            error: Some(DnDError::ProfileManager500),
                            content: None,
                        },
                        StatusCode::NOT_FOUND => Message {
                            error: Some(DnDError::ProfileManagerUserNotFound),
                            content: None,
                        },
                        StatusCode::GATEWAY_TIMEOUT => Message {
                            error: Some(DnDError::ProfileManagerTimeout),
                            content: None,
                        },
                        _ => Message {
                            error: Some(DnDError::ProfileManagerUnableToDeleteNorm),
                            content: None,
                        },
                    }
                }
            }
            Err(e) => {
                log::error!("{:?}", e);
                Message {
                    error: Some(DnDError::ProfileManagerTimeout),
                    content: None,
                }
            }
        };
        if previous_msg.error.is_some() {
            return web::Json(previous_msg);
        }
    }
    let norm = entry.to_norm();
    let res = send_one_norm(&norm, &dnd_entry.userid).await;
    let res = match res {
        Ok(status) => {
            if status.is_success() {
                Message {
                    content: None,
                    error: None,
                }
            } else {
                match status {
                    StatusCode::INTERNAL_SERVER_ERROR => Message {
                        error: Some(DnDError::ProfileManager500),
                        content: None,
                    },
                    StatusCode::NOT_FOUND => Message {
                        error: Some(DnDError::ProfileManagerUserNotFound),
                        content: None,
                    },
                    StatusCode::GATEWAY_TIMEOUT => Message {
                        error: Some(DnDError::ProfileManagerTimeout),
                        content: None,
                    },
                    _ => Message {
                        error: Some(DnDError::ProfileManagerUnableToCreateNorm),
                        content: None,
                    },
                }
            }
        }
        Err(e) => {
            log::error!("{:?}", e);
            Message {
                error: Some(DnDError::ProfileManagerTimeout),
                content: None,
            }
        }
    };
    let user_action = UserAction {
        entry: (*entry).clone(),
        action: EntryAction::Create,
        userid: dnd_entry.userid.clone(),
        status: format!("{:?}", res),
    };
    save_user_action(user_action).await;
    web::Json(res)
}
/// add DnDEntry - create a norm
///
/// # Arguments
///
/// * `entry` - DnDEntry in json
#[get("/get_entries/{userid}")]
async fn get_entries(path: web::Path<(String,)>, req: HttpRequest) -> impl Responder {
    let data = req.app_data::<Data<Sender<String>>>().unwrap();
    let res = data.send("salut".to_string());
    info!("{:?}", res);
    let (userid,) = path.into_inner();
    let mut norms: Vec<Norm> = vec![];
    let res = get_all_norms(&userid, &mut norms).await;
    let res = match res {
        Ok(status) => {
            if status.is_success() {
                let mut entries: Vec<DnDEntry> = vec![];
                for norm in norms {
                    if let Some(entry) = norm.to_dnd_entry() {
                        entries.push(entry);
                    }
                }
                Message {
                    content: Some(Content::Entries(entries)),
                    error: None,
                }
            } else {
                match status {
                    StatusCode::INTERNAL_SERVER_ERROR => Message {
                        error: Some(DnDError::ProfileManager500),
                        content: None,
                    },
                    StatusCode::NOT_FOUND => Message {
                        error: Some(DnDError::ProfileManagerUserNotFound),
                        content: None,
                    },
                    StatusCode::GATEWAY_TIMEOUT => Message {
                        error: Some(DnDError::ProfileManagerTimeout),
                        content: None,
                    },
                    _ => Message {
                        error: Some(DnDError::UnknownError),
                        content: None,
                    },
                }
            }
        }
        Err(e) => {
            log::error!("{:?}", e);
            Message {
                error: Some(DnDError::ProfileManagerTimeout),
                content: None,
            }
        }
    };
    web::Json(res)
}

#[get("/get_code")]
async fn get_code(code: web::Query<Code>) -> impl Responder {
    // session
    let code = code.code.clone();
    info!("requested /get_code with code {}", code);

    let secret = env::var("WENET_SECRET").unwrap_or_default();
    let client_id = env::var("OAUTH2_CLIENT_ID").unwrap_or_default();
    let client_secret = env::var("OAUTH2_CLIENT_SECRET").unwrap_or_default();
    let grant_type = "authorization_code".to_owned();
    let mut access_token = "".to_owned();
    let oauth2_request = OAuth2TokenRequest {
        client_id: client_id,
        client_secret: client_secret,
        code: code,
        grant_type: grant_type,
    };

    let url = "https://internetofus.u-hopper.com/prod/api/oauth2/token";
    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .header("x-wenet-component-apikey", secret)
        .header("Authorization", "test:wenet")
        .header("Content-Type", "application/json")
        .header("Accept", "application/json")
        .json(&oauth2_request)
        .send()
        .await;
    if let Ok(res) = res {
        let content: Result<OAuth2TokenResponse, _> = res.json().await;
        if let Ok(content) = content {
            access_token = content.access_token;
            info!("token was retrieved successfuly");
        } else {
            warn!("issue when decoding the OAuth2TokenResponse");
        }
    } else {
        warn!("issue while requesting the token");
    }

    // TODO change hard-coded
    let counter = 1;
    let page = format!(
        "<html>
    <head><title>redirection</title></head>
    <body>
    <p>test {counter} </p>
    <script>
        localStorage.setItem('token', '{}');
        setTimeout(\"location.href = 'https://lab.idiap.ch/devel/hub/wenet/dnd/';\",1500);
    </script>
    </body>
    </html>",
        access_token
    );
    // set counter to session
    //let _ = session.insert("counter", counter);

    // response
    HttpResponse::Ok().content_type("text/html").body(page)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    let port = env::var("DND_PORT").unwrap_or("8888".to_owned());
    let port = port.parse::<u16>().expect("bad port number");
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    let (tx_save, rx_save) = flume::unbounded::<String>();
    actix_rt::spawn(async move {
        while let Ok(message) = rx_save.recv() {
            info!("received msg {}", message);
        }
    });
    let data = Data::new(tx_save);
    HttpServer::new(move || {
        App::new()
            .wrap(Logger::new("%{r}a asks %U"))
            .app_data(Data::clone(&data))
            .service(add_entry)
            .service(get_entries)
            .service(delete_entry)
            .service(get_code)
            .service(
                fs::Files::new("/", "./static")
                    .index_file("index.html")
                    .use_last_modified(true),
            )
    })
    .bind(("0.0.0.0", port))?
    .disable_signals()
    .run()
    .await
}
