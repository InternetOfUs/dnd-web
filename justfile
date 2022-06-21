dnd_front := "frontend/dnd_front"
dnd_back := "backend/dnd_back"

run-front:
    cd {{ dnd_front }} && flutter run -d web-server --web-port 8888

run-back:
    cd {{ dnd_back }} && cargo run

flutter CMD:
    cd {{ dnd_front }} && flutter {{ CMD }}

cargo CMD:
    cd {{ dnd_back }} && cargo {{ CMD }}

build-front:
    just flutter "build web --release"

build-back:
    just cargo "build --release"

copy-front-to-back:
    cp -rv {{ dnd_front }}/web/* {{ dnd_back }}/static/

build: build-front copy-front-to-back build-back

run:
    {{ dnd_back }}/target/release/dnd_back
