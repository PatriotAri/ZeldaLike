extends Camera2D

##sets camera smoothing, should not be touched
@export var smoothing_speed := 6.5

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed

func apply_world_bounds(bounds_layer: TileMapLayer) -> void:
	if bounds_layer == null:
		push_warning("Camera: WorldBounds layer is null")
		return

	# Rect in TILE coordinates
	var used_rect: Rect2i = bounds_layer.get_used_rect()
	if used_rect == Rect2i():
		push_warning("Camera: WorldBounds has no tiles")
		return

	var tile_size: Vector2i = bounds_layer.tile_set.tile_size

	# Convert tile-space → world-space (pixels)
	limit_left   = used_rect.position.x * tile_size.x
	limit_top    = used_rect.position.y * tile_size.y
	limit_right  = (used_rect.position.x + used_rect.size.x) * tile_size.x
	limit_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y
