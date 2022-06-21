dnd_front := "frontend/dnd_front"
dnd_back := "backend/dnd_back"

# run only the frontend
run-front:
    cd {{ dnd_front }} && flutter run -d web-server --web-port 8888

# run only the backend
run-back:
    cd {{ dnd_back }} && cargo run

# run given flutter CMD for the frontend
flutter CMD:
    cd {{ dnd_front }} && flutter {{ CMD }}

# run given cargo CMD for the backend
cargo CMD:
    cd {{ dnd_back }} && cargo {{ CMD }}

# build the frontend
build-front:
    just flutter "build web --release"

# build the backend
build-back:
    just cargo "build --release"

# copy builded frontend into the backend
copy-front-to-back:
    cp -rv {{ dnd_front }}/web/* {{ dnd_back }}/static/

# Build all
build: build-front copy-front-to-back build-back

# Run the app
run:
    {{ dnd_back }}/target/release/dnd_back
