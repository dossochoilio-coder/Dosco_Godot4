# src/ui/StarPiece.gd
extends Node2D

var coord: String = ""
var _color: String = "W"
var _type: String  = "Sirus"
var _rect: ColorRect = null

const COL_WHITE: Color = Color(0.96, 0.97, 1.00)
const COL_BLUE:  Color = Color(0.40, 0.65, 1.00)

func setup(type_name: String, piece_color: String) -> void:
	_type  = type_name
	_color = piece_color
	if _rect == null:
		_rect = ColorRect.new()
		_rect.size = Vector2(32.0, 32.0)
		_rect.position = Vector2(-16.0, -16.0)
		add_child(_rect)
	_rect.color = COL_WHITE if piece_color == "W" else COL_BLUE

func play_capture_effect() -> void:
	# Effet simple sans scène externe
	var tw: Tween = create_tween()
	tw.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tw.tween_property(self, "scale", Vector2.ZERO,      0.15)
	tw.tween_callback(queue_free)
