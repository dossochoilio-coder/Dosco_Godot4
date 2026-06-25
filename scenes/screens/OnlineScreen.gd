# scenes/screens/OnlineScreen.gd
extends Control

func _ready() -> void:
    pass

func _start_search() -> void:
    # Correction : la fonction prend seulement 1 argument
    if NetworkManager.is_connected_to_server():
        NetworkManager.find_match("voie_lactee")
    else:
        NetworkManager.connect_to_server(GameManager.current_user.get("name", "Joueur"))
