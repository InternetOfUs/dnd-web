use actix_files as fs;
use actix_web::{middleware::Logger, App, HttpServer};
use std::env;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));
    let path = env::current_dir()?;
    println!("The current directory is {}", path.display());
    HttpServer::new(|| {
        App::new().wrap(Logger::new("%a %{User-Agent}i")).service(
            fs::Files::new("/", "./static")
                .index_file("index.html")
                .use_last_modified(true),
        )
    })
    .bind(("127.0.0.1", 8888))?
    .run()
    .await
}
