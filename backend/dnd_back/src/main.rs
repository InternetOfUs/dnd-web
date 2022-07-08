use actix_files as fs;
use actix_web::get;
use actix_web::{middleware::Logger, post, web, App, HttpResponse, HttpServer, Responder};
use dotenvy::dotenv;
use log::{info, warn};
use reqwest::{self, StatusCode};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::env;
use std::fmt::{self};

/// One DnDEntry of the user (TODO change name)
#[derive(Deserialize, Serialize)]
struct DnDEntry {
    /// Week of the day, 1 Monday .. 7 Sunday
    weekday: i32,
    /// From when DnD
    time_from: String,
    /// To
    time_to: String,
    /// Where the user is usually
    label: String,
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
        norm.description = Some(format!("DND_{}", norm.compute_id()));
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

/// Norm associated with a user
#[derive(Deserialize)]
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
#[derive(Deserialize, Serialize)]
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

    fn to_dnd_entry(&self) -> Option<DnDEntry> {
        if let Some(desc) = self.description.clone() {
            if desc.contains("DND_") {
                // TODO changeme
                return Some(DnDEntry {
                    weekday: 0,
                    time_from: "00:00".to_string(),
                    time_to: "00:00".to_string(),
                    label: "home".to_string(),
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

/// add DnDEntry - create a norm
///
/// # Arguments
///
/// * `entry` - DnDEntry in json
#[post("/add_entry")]
async fn add_entry(dnd_entry: web::Json<DnDEntryWitUser>) -> impl Responder {
    let entry = &dnd_entry.entry;
    println!("received {}", entry);
    let norm = entry.to_norm();
    let res = send_one_norm(&norm, &dnd_entry.userid).await;
    let msg = match res {
        Ok(status) => status.to_string(),
        Err(err) => format!("error while transporting to Profile Manager {err}"),
    };
    info!("msg : {msg}");
    HttpResponse::Ok().body(format!("msg : {msg}"))
}

/// add DnDEntry - create a norm
///
/// # Arguments
///
/// * `entry` - DnDEntry in json
#[get("/get_entries/{userid}")]
async fn get_entries(path: web::Path<(String,)>) -> impl Responder {
    let (userid,) = path.into_inner();
    let mut norms: Vec<Norm> = vec![];
    let res = get_all_norms(&userid, &mut norms).await;
    match res {
        Ok(status) => {
            if status.is_success() {
                let mut entries: Vec<DnDEntry> = vec![];
                for norm in norms {
                    if let Some(entry) = norm.to_dnd_entry() {
                        entries.push(entry);
                    }
                }
                return web::Json(entries);
            } else {
                info!(
                    "issue while getting norm from Profile Manager {}",
                    status.as_str()
                );
                return web::Json(vec![]);
            }
        }
        Err(err) => {
            warn!("error while getting norm from Profile Manager {err}");
            return web::Json(vec![]);
        }
    };
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    HttpServer::new(|| {
        App::new()
            .wrap(Logger::new("%a %{User-Agent}i"))
            .service(add_entry)
            .service(get_entries)
            .service(
                fs::Files::new("/", "./static")
                    .index_file("index.html")
                    .use_last_modified(true),
            )
    })
    .bind(("0.0.0.0", 8888))?
    .run()
    .await
}
