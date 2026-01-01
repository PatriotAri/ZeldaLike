extends Node2D

@onready var player: Node2D = $PlayerCharacter
@onready var camera: Camera2D = $PlayerCharacter/CharacterBody2D/Camera2D

var current_level: Node2D


func _ready() -> void:
	load_level("res://scenes/levels/test/test_level.tscn")


func load_level(level_path: String) -> void:
	# Remove old level if it exists
	if current_level:
		current_level.queue_free()

	# Instance new level
	var level_scene: PackedScene = load(level_path)
	current_level = level_scene.instantiate()
	add_child(current_level)

	# Defer camera setup by one frame
	await get_tree().process_frame

	apply_camera_bounds()


func apply_camera_bounds() -> void:
	if not current_level:
		return

	var bounds_layer := current_level.get_node_or_null("WorldBounds")
	if bounds_layer == null:
		push_warning("Game: Level has no WorldBounds layer")
		return

	camera.apply_world_bounds(bounds_layer)
