dnd_front := "frontend/dnd_front"

run-front:
    cd {{dnd_front}} && flutter run -d web-server --web-port 8888

flutter CMD:
    cd {{dnd_front}} && flutter {{CMD}}