# src/ui/BoardCell.gd
extends Control
class_name BoardCell

signal pressed(coord: String)

@export var coord: String = ""
@export var cell_size: float = 50.0

var is_selected := false
var is_valid_move := false
var is_valid_capture := false

@onready var background: ColorRect = $Background
@onready var highlight: ColorRect = $Highlight
@onready var capture_indicator: ColorRect = $CaptureIndicator

func _ready() -> void:
    custom_minimum_size = Vector2(cell_size, cell_size)
    size = Vector2(cell_size, cell_size)
    _update_visual_state()

func set_state(selected: bool, valid_move: bool, valid_capture: bool) -> void:
    is_selected = selected
    is_valid_move = valid_move
    is_valid_capture = valid_capture
    _update_visual_state()

func _update_visual_state() -> void:
    if not is_node_ready(): return
    background.color = Color(0.035, 0.045, 0.09, 0.9)
    highlight.visible = is_selected or is_valid_move or is_valid_capture

    if is_selected:
        highlight.color = Color(0.3, 0.65, 1.0, 0.45)
    elif is_valid_capture:
        highlight.color = Color(1.0, 0.35, 0.35, 0.5)
    elif is_valid_move:
        highlight.color = Color(0.2, 0.9, 0.6, 0.35)
    else:
        highlight.visible = false

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        pressed.emit(coord)
        HapticManager.selection()
