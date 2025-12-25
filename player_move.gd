func update_state(direction: Vector2):
	match state:
		PlayerState.IDLE:
			velocity = Vector2.ZERO
			
		PlayerState.WALK:
			velocity = direction * player_walk_speed
			
		PlayerState.RUN:
			velocity = direction * player_run_speed
