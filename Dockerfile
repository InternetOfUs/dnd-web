# syntax=docker/dockerfile:1

# build the frontend
FROM cirrusci/flutter:3.0.2 AS build_front


COPY frontend /build/frontend/

WORKDIR /build/frontend/dnd_front/

# clean, useful when non-ci building of the container
RUN flutter clean

# build web (static html, css and JS)
RUN flutter build web --release

# build the backend
# use custom image for static build with musls
FROM ekidd/rust-musl-builder:latest as build_back

COPY --chown=rust:rust backend /build/backend/

WORKDIR /build/backend/dnd_back/

# clean, useful when non-ci building of the container
RUN cargo clean

# build in release mode
RUN cargo build --release

# deployed container
FROM scratch

COPY --from=build_back /build/backend/dnd_back/target/x86_64-unknown-linux-musl/release/dnd_back /app/
COPY --from=build_front /build/frontend/dnd_front/build/web /app/static
WORKDIR /app
EXPOSE 8888
CMD ["/app/dnd_back"]
