dnd_front := "frontend/dnd_front"
dnd_back := "backend/dnd_back"

run-front:
    cd {{ dnd_front }} && flutter run -d web-server --web-port 8888

run-back:
    cd {{ dnd_back }} && cargo run

flutter CMD:
    cd {{ dnd_front }} && flutter {{ CMD }}
