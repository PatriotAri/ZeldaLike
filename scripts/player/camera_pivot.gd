extends Node2D
@export var look_ahead_distance := 5.0
@export var look_ahead_speed := 3.0

@onready var body := get_parent() as CharacterBody2D

func _physics_process(delta: float) -> void:
	if body == null:
		return

	var target_offset := Vector2.ZERO

	if body.velocity.length() > 5.0:
		target_offset = body.velocity.normalized() * look_ahead_distance

	position = position.move_toward(
		target_offset,
		look_ahead_speed * delta * look_ahead_distance
	)
