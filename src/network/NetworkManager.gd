# src/network/NetworkManager.gd
extends Node

signal connected_to_server
signal game_started(data: Dictionary)
signal move_received(data: Dictionary)
signal game_ended(data: Dictionary)
signal error_received(msg: String)

var _ws: WebSocketPeer = null
var _game_id: String = ""

const SERVER := "wss://dosco-backend-production.up.railway.app"

func connect_to_server(player_name: String) -> void:
    _ws = WebSocketPeer.new()
    # In a real implementation, first do HTTP auth then connect WS
    var err = _ws.connect_to_url(SERVER)
    if err == OK:
        connected_to_server.emit()

func find_match(galaxy_id: String, stake: int = 0) -> void:
    if _ws:
        _ws.send_text(JSON.stringify({
            "type": "find_match",
            "galaxy": galaxy_id,
            "stars": stake
        }))

func send_move(from_coord: String, to_coord: String) -> void:
    if _ws and not _game_id.is_empty():
        _ws.send_text(JSON.stringify({
            "type": "move",
            "gameId": _game_id,
            "from": from_coord,
            "to": to_coord
        }))
