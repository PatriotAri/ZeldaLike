extends Node2D

# Node references
@onready var body: CharacterBody2D = $CharacterBody2D
@onready var sprite: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var patrol_root: Node2D = $PatrolPoints

# Enemy intent states
enum EnemyState {
	IDLE,    # Intentional standstill (guards, stunned, waiting)
	PATROL,  # Moving between patrol points
	ALERT,   #Recently lost player timer
	CHASE    # Actively pursuing the player
}

@export var initial_state := EnemyState.PATROL
#Change to EnemyState.IDLE for guards, stealh enemies
var state := EnemyState.PATROL

# Movement tuning
@export var max_speed := 40.0
@export var acceleration := 400.0
@export var deceleration := 600.0

# Animation thresholds (velocity-based)
@export var walk_speed_threshold := 8.0
@export var run_speed_threshold := 28.0

# Patrol tuning
@export var patrol_pause_time := 0.5
var patrol_points: Array[Node2D] = []
var patrol_index := 0
var patrol_timer := 0.0

# Alert tuning
@export var alert_duration := 2.0        # seconds enemy stays alert
@export var alert_slow_factor := 0.4     # movement speed during alert

var alert_timer := 0.0

# Runtime data
var target: CharacterBody2D = null
var facing := Vector2.DOWN

# Ready
func _ready() -> void:
	# Decide initial state safely
	if initial_state == EnemyState.PATROL:
		if patrol_points.is_empty():
			state = EnemyState.IDLE
			push_warning("Enemy set to PATROL but has no PatrolPoints — defaulting to IDLE")
		else:
			state = EnemyState.PATROL
	else:
		state = initial_state
	
	# Cache patrol points (if any)
	if patrol_root:
		for child in patrol_root.get_children():
			if child is Node2D:
				patrol_points.append(child)

	# Detection signals
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

# Physics loop
func _physics_process(delta: float) -> void:
	match state:
		EnemyState.IDLE:
			body.velocity = body.velocity.move_toward(
				Vector2.ZERO,
				deceleration * delta
			)

		EnemyState.PATROL:
			patrol(delta)

		EnemyState.ALERT:
			alert(delta)

		EnemyState.CHASE:
			if target:
				var dir := (target.global_position - body.global_position).normalized()
				var target_velocity := dir * max_speed
				body.velocity = body.velocity.move_toward(
					target_velocity,
					acceleration * delta
				)

	body.move_and_slide()
	update_facing()
	update_animation()

# Patrol behavior
func patrol(delta: float) -> void:
	if patrol_points.is_empty():
		body.velocity = body.velocity.move_toward(
			Vector2.ZERO,
			deceleration * delta
		)
		return

	var target_point := patrol_points[patrol_index]
	var to_target := target_point.global_position - body.global_position
	var distance := to_target.length()

	# Arrived at patrol point
	if distance < 6.0:
		patrol_timer += delta
		body.velocity = body.velocity.move_toward(
			Vector2.ZERO,
			deceleration * delta
		)

		if patrol_timer >= patrol_pause_time:
			patrol_timer = 0.0
			patrol_index = (patrol_index + 1) % patrol_points.size()
		return

	# Move toward patrol point
	var dir := to_target.normalized()
	var target_velocity := dir * (max_speed * 0.6)
	body.velocity = body.velocity.move_toward(
		target_velocity,
		acceleration * delta
	)

func alert(delta: float) -> void:
	alert_timer += delta

	# Slowly come to a stop
	body.velocity = body.velocity.move_toward(
		Vector2.ZERO,
		deceleration * delta
	)

	# Optional: small wandering motion (comment out if undesired)
	# body.velocity += Vector2(randf() - 0.5, randf() - 0.5) * 5.0

	if alert_timer >= alert_duration:
		alert_timer = 0.0
		state = EnemyState.PATROL   # or IDLE for guard enemies

# Detection callbacks
func _on_body_entered(node: Node) -> void:
	if node is CharacterBody2D:
		target = node
		state = EnemyState.CHASE
		
func _on_body_exited(node: Node) -> void:
	if node == target:
		target = null
		alert_timer = 0.0
		state = EnemyState.ALERT

# Facing logic (velocity-driven)
func update_facing() -> void:
	if body.velocity.length() > 5.0:
		facing = body.velocity.normalized()

# Animation logic
func update_animation() -> void:
	var speed := body.velocity.length()
	var dir_name := direction_to_name(facing)

	var anim := ""
	if speed < walk_speed_threshold:
		anim = "idle_" + dir_name
	elif speed < run_speed_threshold:
		anim = "walk_" + dir_name
	else:
		anim = "run_" + dir_name

	if sprite.animation != anim:
		sprite.play(anim)

# Direction helper (8-direction)
func direction_to_name(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		return direction_to_name(facing)

	var angle := dir.angle()
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
