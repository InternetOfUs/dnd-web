use std::fmt::{self};

use actix_files as fs;
use actix_web::{middleware::Logger, post, web, App, HttpResponse, HttpServer, Responder};
use serde::Deserialize;

#[derive(Deserialize)]
struct Routine {
    weekday: i32,
    time_from: String,
    time_to: String,
    label: String,
}

impl fmt::Display for Routine {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} - {} - {} - {}",
            self.weekday, self.time_from, self.time_to, self.label
        )
    }
}

#[derive(Deserialize)]
struct NormWithUser {
    userid: String,
    norm: Norm,
}

impl fmt::Display for NormWithUser {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} - {}", self.userid, self.norm)
    }
}

#[derive(Deserialize)]
struct Norm {
    description: String,
    whenever: String,
    thenceforth: String,
}

impl fmt::Display for Norm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "\n\tdesc: {}\n\twhen: {}\n\tthen: {}",
            self.description, self.whenever, self.thenceforth
        )
    }
}

/// add routine - create a norm
///
/// # Arguments
///
/// * `routine` - routine in json
#[post("/add_routine")]
async fn add_routine(routine: web::Json<Routine>) -> impl Responder {
    println!("received {}", routine);
    HttpResponse::Ok().body(routine.to_string())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    HttpServer::new(|| {
        App::new()
            .wrap(Logger::new("%a %{User-Agent}i"))
            .service(add_routine)
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
