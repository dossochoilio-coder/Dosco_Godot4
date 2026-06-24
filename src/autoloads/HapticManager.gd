# src/autoloads/HapticManager.gd
extends Node

var _enabled: bool = true

func _vibrate(duration_ms: int) -> void:
    if _enabled and OS.has_feature("mobile"):
        Input.vibrate_handheld(duration_ms)

func selection() -> void: _vibrate(15)
func move() -> void: _vibrate(25)
func capture() -> void: _vibrate(55)
func victory() -> void: _vibrate(90)
func light() -> void: _vibrate(20)
func medium() -> void: _vibrate(40)
