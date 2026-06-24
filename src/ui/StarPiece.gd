# src/ui/StarPiece.gd
extends Node2D
class_name StarPiece

@export var coord: String = ""
@export var star_type: String = "Sirus"
@export var piece_color: String = "W"

@onready var sprite: Sprite2D = $Sprite
@onready var glow: Sprite2D = $Glow

func setup(type: String, color: String) -> void:
    star_type = type
    piece_color = color
    _apply_visual_style()

func _apply_visual_style() -> void:
    if piece_color == "W":
        if sprite: sprite.modulate = Color(0.96, 0.97, 1.0)
        if glow: glow.modulate = Color(0.35, 0.72, 1.0, 0.7)
    else:
        if sprite: sprite.modulate = Color(0.55, 0.72, 1.0)
        if glow: glow.modulate = Color(0.25, 0.55, 1.0, 0.75)

    if glow:
        var tween := create_tween().set_loops()
        tween.tween_property(glow, "modulate:a", 0.45, 1.3)
        tween.tween_property(glow, "modulate:a", 0.8, 1.3)

func play_move_animation(target_pos: Vector2) -> void:
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "global_position", target_pos, 0.22)

func play_capture_animation() -> void:
    HapticManager.capture()
    # Spawn capture effect
    var effect_scene := preload("res://scenes/effects/CaptureEffect.tscn")
    if ResourceLoader.exists(effect_scene.resource_path):
        var effect := effect_scene.instantiate()
        effect.global_position = global_position
        get_tree().current_scene.add_child(effect)
    
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.12)
    tween.tween_property(self, "modulate:a", 0.0, 0.25)
    tween.tween_callback(queue_free)
