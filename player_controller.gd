extends CharacterBody2D
##gets script ready to use for future use with 2D sprite animation
@onready var sprite: AnimatedSprite2D =  $AnimatedSprite2D

enum PlayerState {IDLE, WALK, RUN}

@export var walk_speed := 50.0
@export var run_speed := 75.0
@export var health := 10.0

var state := PlayerState.IDLE
var input_dir := Vector2.ZERO
var facing := Vector2.DOWN

##Input -> update player state (idle, run,  walk, etc.) -> Move player according to state
func _physics_process(delta):
	input_dir = read_input()
	update_state()
	apply_movement()
	update_animation()

##gets player input
func read_input() -> Vector2:
	var dir := Vector2.ZERO

	dir.x = Input.get_action_strength("player_move_right") \
		  - Input.get_action_strength("player_move_left")

	dir.y = Input.get_action_strength("player_move_down") \
		  - Input.get_action_strength("player_move_up")

	return dir.normalized()
	
##updates the player state
func update_state():
	match state:
		PlayerState.IDLE:
			if input_dir != Vector2.ZERO:
				state = PlayerState.WALK
				facing = input_dir
				
		PlayerState.WALK:
			if input_dir == Vector2.ZERO:
				state = PlayerState.IDLE
			elif Input.is_action_pressed("player_run"):
				state = PlayerState.RUN
			else:
				facing = input_dir
				
		PlayerState.RUN:
			if input_dir == Vector2.ZERO:
				state = PlayerState.IDLE
			elif not Input.is_action_pressed("player_run"):
				state = PlayerState.WALK
			else:
				facing = input_dir

##moves the player accoring to the state
func apply_movement():
	match state:
		PlayerState.IDLE:
			velocity = Vector2.ZERO
			
		PlayerState.WALK:
			velocity = input_dir * walk_speed
			
		PlayerState.RUN:
			velocity = input_dir * run_speed
	
	move_and_slide()

func update_animation():
	##set default direction to down
	var dir := "down"
	##reset flip every fram to false(IMPORTANT)
	sprite.flip_h = false
	
	if facing == Vector2.UP:
		dir = "up"
	if facing == Vector2.DOWN:
		dir = "down"
	if facing == Vector2.LEFT:
		dir = "side"
		sprite.flip_h = true
	if facing == Vector2.RIGHT:
		dir = "side"
		sprite.flip_h = false
		
	var anim_name := ""
	match state:
		PlayerState.IDLE:
			anim_name = "idle_" + dir
		PlayerState.WALK, PlayerState.RUN:
			anim_name = "walk_" + dir
		
	if sprite.animation != anim_name:
		sprite.play(anim_name)
