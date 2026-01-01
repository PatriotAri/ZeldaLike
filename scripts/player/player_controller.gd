extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum PlayerState { IDLE, WALK, RUN }

@export var health := 10.0

@export var walk_speed := 50.0
@export var run_speed := 80.0
##controls ac/deceleration for player
@export var acceleration := 800.0
@export var deceleration := 1000.0
##sets speed to activate player state
@export var idle_speed_threshold := 5.0
@export var run_speed_threshold := 65.0


var state := PlayerState.IDLE
var input_dir := Vector2.ZERO
var facing := Vector2.DOWN

func _ready():
	global_position = Vector2(0, -16)
	

func _physics_process(_delta):
	input_dir = read_input()
	apply_movement()
	update_state()
	update_animation()

func read_input() -> Vector2:
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("player_move_right") - Input.get_action_strength("player_move_left")
	dir.y = Input.get_action_strength("player_move_down") - Input.get_action_strength("player_move_up")
	
	if dir.length() < 0.1:
		return Vector2.ZERO
	
	return dir.normalized()

func update_state():
	var speed := velocity.length()

	if speed < idle_speed_threshold and input_dir == Vector2.ZERO:
		state = PlayerState.IDLE
	elif speed >= run_speed_threshold and Input.is_action_pressed("player_run"):
		state = PlayerState.RUN
	else:
		state = PlayerState.WALK

	if input_dir != Vector2.ZERO:
		facing = input_dir

func apply_movement():
	var target_velocity := Vector2.ZERO

	match state:
		PlayerState.IDLE:
			target_velocity = Vector2.ZERO

		PlayerState.WALK:
			target_velocity = input_dir * walk_speed

		PlayerState.RUN:
			target_velocity = input_dir * run_speed

	# Choose accel or decel based on intent
	var accel := acceleration if target_velocity != Vector2.ZERO else deceleration

	velocity = velocity.move_toward(target_velocity, accel * get_physics_process_delta_time())
	move_and_slide()

func update_animation():
	var dir_name := direction_to_name(facing)

	var anim_name := ""
	match state:
		PlayerState.IDLE:
			anim_name = "idle_" + dir_name
		PlayerState.WALK:
			anim_name = "walk_" + dir_name
		PlayerState.RUN:
			anim_name = "run_" + dir_name

	if sprite.animation != anim_name:
		sprite.play(anim_name)

func direction_to_name(dir: Vector2) -> String:
	# 8-direction mapping using angle
	if dir == Vector2.ZERO:
		return direction_to_name(facing)

	var angle := dir.angle() # -PI to PI
	# Convert angle to 8 sectors (each 45°)
	var sector := int(round(angle / (PI / 4.0))) & 7

	match sector:
		0:  return "right"
		1:  return "down_right"
		2:  return "down"
		3:  return "down_left"
		4:  return "left"
		5:  return "up_left"
		6:  return "up"
		7:  return "up_right"
		_:  return "down"
