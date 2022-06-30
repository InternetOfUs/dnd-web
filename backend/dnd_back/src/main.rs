use actix_files as fs;
use actix_web::{middleware::Logger, post, App, HttpResponse, HttpServer, Responder};

#[post("/add_norms")]
async fn echo(req_body: String) -> impl Responder {
    HttpResponse::Ok().body(req_body)
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
