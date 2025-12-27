extends Camera2D

@onready var world_bounds: TileMapLayer = $"../../TestLevel/TileMap/WorldBounds"
@onready var tilemap: TileMap = world_bounds.get_parent()

func _ready() -> void:
	await get_tree().process_frame
	setup_camera_limits()

func setup_camera_limits() -> void:
	if not world_bounds or not tilemap:
		return

	var used_rect: Rect2i = world_bounds.get_used_rect()
	var tile_size: Vector2i = tilemap.tile_set.tile_size

	limit_left   = used_rect.position.x * tile_size.x
	limit_top    = used_rect.position.y * tile_size.y
	limit_right  = used_rect.end.x * tile_size.x
	limit_bottom = used_rect.end.y * tile_size.y
