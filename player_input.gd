func get_player_dir() -> Vector2:
	return Input.get_vector("player_move_up", "player_move_down", "player_move_left", "player_move_right")
