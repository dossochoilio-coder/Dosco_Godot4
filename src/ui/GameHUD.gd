# src/ui/GameHUD.gd
extends Control
class_name GameHUD

@onready var turn_label: Label = $TopBar/TurnLabel
@onready var status_label: Label = $TopBar/StatusLabel

var game_state_ref: GameState = null

func update_hud(state: GameState) -> void:
    game_state_ref = state
    if state == null:
        return

    if state.is_finished():
        var winner = state.get_winner()
        if winner == state.player_color:
            status_label.text = "VICTOIRE"
            status_label.modulate = Color(0.3, 0.9, 0.6)
        else:
            status_label.text = "DÉFAITE"
            status_label.modulate = Color(1.0, 0.45, 0.5)
        turn_label.text = ""
    else:
        turn_label.text = "TON TOUR" if state.turn == state.player_color else "TOUR ADVERSAIRE"
        status_label.text = ""
