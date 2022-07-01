use std::fmt::{self};

use actix_files as fs;
use actix_web::{middleware::Logger, post, web, App, HttpResponse, HttpServer, Responder};
use serde::Deserialize;

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

#[post("/add_norms")]
async fn echo(norm_with_user: web::Json<NormWithUser>) -> impl Responder {
    println!("received {}", norm_with_user);
    HttpResponse::Ok().body(norm_with_user.userid.clone())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    HttpServer::new(|| {
        App::new().wrap(Logger::new("%a %{User-Agent}i")).service(
            fs::Files::new("/", "./static")
                .index_file("index.html")
                .use_last_modified(true),
        )
    })
    .bind(("0.0.0.0", 8888))?
    .run()
    .await
}
