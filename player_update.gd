func player_update():
	#gets input form player_input.gd
	var direction = get_player_dir()
	#tells the game your player is not idle
	var is_moving = direction != Vector2.ZERO
	#tells the game your player is running
	var is_running = Input.is_action_pressed("player_run")
	
	if not is_moving:
		state = PlayerState.IDLE
	elif is_running:
		state = PlayerState.RUN
	else:
		state = PlayerState.WALK
		
	update_state(direction)
