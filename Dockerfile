# syntax=docker/dockerfile:1
FROM cirrusci/flutter:3.0.2 AS build_front


COPY frontend /build/frontend/

WORKDIR /build/frontend/dnd_front/

RUN flutter clean
RUN flutter build web --release

FROM ekidd/rust-musl-builder:latest as build_back

COPY --chown=rust:rust backend /build/backend/

WORKDIR /build/backend/dnd_back/

RUN mkdir -p static
COPY --from=build_front /build/frontend/dnd_front/web/* /build/backend/dnd_back/static/

RUN cargo clean
RUN cargo build --release

FROM scratch

COPY --from=build_back /build/backend/dnd_back/target/x86_64-unknown-linux-musl/release/dnd_back /app/
WORKDIR /app
EXPOSE 8888
CMD ["/app/dnd_back"]
