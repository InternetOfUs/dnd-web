use actix_files as fs;
use actix_web::{middleware::Logger, post, web, App, HttpResponse, HttpServer, Responder};
use dotenvy::dotenv;
use serde::{Deserialize, Serialize};
use std::env;
use std::fmt::{self};

/// One DnDEntry of the user (TODO change name)
#[derive(Deserialize)]
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
struct NormWithUser {
    /// User id - owner of the norm
    userid: String,
    /// The norm
    norm: Norm,
}

impl fmt::Display for NormWithUser {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} - {}", self.userid, self.norm)
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

/// add DnDEntry - create a norm
///
/// # Arguments
///
/// * `entry` - DnDEntry in json
#[post("/add_entry")]
async fn add_entry(entry: web::Json<DnDEntry>) -> impl Responder {
    println!("received {}", entry);
    HttpResponse::Ok().body(entry.to_string())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    HttpServer::new(|| {
        App::new()
            .wrap(Logger::new("%a %{User-Agent}i"))
            .service(add_entry)
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
