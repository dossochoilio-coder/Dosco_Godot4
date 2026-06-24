# scenes/effects/CaptureEffect.gd
extends Node2D

@export var lifetime: float = 0.6

@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
    if particles:
        particles.emitting = true
    await get_tree().create_timer(lifetime).timeout
    queue_free()
