# syntax=docker/dockerfile:1

# build the frontend
FROM cirrusci/flutter:3.0.2 AS build_front


COPY frontend /build/frontend/

WORKDIR /build/frontend/dnd_front/

# clean, useful when non-ci building of the container
RUN flutter clean

# build only if tests pass
RUN flutter test

# build web (static html, css and JS)
RUN flutter build web --release --base-href "/devel/hub/wenet/dnd/"

# build the backend
# use custom image for static build with musls
FROM rust:1.62.1 as build_back

COPY backend /build/backend/

WORKDIR /build/backend/dnd_back/

# clean, useful when non-ci building of the container
RUN cargo clean

# build in release mode
RUN cargo install --path .

# deployed container
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates

COPY --from=build_back /usr/local/cargo/bin/dnd_back /app/
COPY --from=build_front /build/frontend/dnd_front/build/web /app/static
WORKDIR /app
EXPOSE 8888
CMD ["/app/dnd_back"]
