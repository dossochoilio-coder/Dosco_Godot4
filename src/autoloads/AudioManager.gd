# src/autoloads/AudioManager.gd
extends Node

func play_sfx(name: String) -> void:
    # Placeholder - in real project, load AudioStreamPlayer nodes
    print("Playing SFX: ", name)

func sfx_click() -> void: play_sfx("click")
func sfx_move() -> void: play_sfx("move")
func sfx_capture() -> void: play_sfx("capture")
func sfx_victory() -> void: play_sfx("victory")
