##This script handles Movement, intent, and timing for enemies.
extends Node2D

enum EnemyState {IDLE, PATROL, CHASE}

# sets paths to nodes
@onready var body: CharacterBody2D = $CharacterBody2D
@onready var patrol_root: Node2D = $PatrolPoints
@onready var detection_area: Area2D = $DetectionArea

# exposes important tuning info to be edited
@export var patrol_speed := 30.0
@export var acceleration := 300.0
@export var arrive_radius := 4.0
@export var initial_state := EnemyState.PATROL
var state: EnemyState

@export var patrol_pause_time := 1.0
var patrol_pause_timer := 0.0
var patrol_points: Array[Node2D] = []
var patrol_index := 0

var chase_target: Node2D = null

# changes enemy state
func change_state(new_state: EnemyState) -> void:
	if state == new_state:
		return
	state = new_state

func on_patrol_point_reached() -> void:
	patrol_index = (patrol_index + 1) % patrol_points.size()
	patrol_pause_timer = 0.0
	change_state(EnemyState.IDLE)

func _ready() -> void:
	# Cache patrol points
	for child in patrol_root.get_children():
		if child is Node2D:
			patrol_points.append(child)

	if patrol_points.size() < 2:
		push_warning("Enemy needs at least 2 patrol points")
	
	# decides if enemy using this base had detection and connects detection accordingly
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)
	
	# decides intent AFTER data exists
	if initial_state == EnemyState.PATROL and patrol_points.size() >= 2:
		change_state(EnemyState.PATROL)
	else:
		change_state(EnemyState.IDLE)
			
	set_physics_process(true)

# counts amount of time during idle
func tick_idle(delta: float) -> void:
	patrol_pause_timer += delta
	
	body.velocity = body.velocity.move_toward(Vector2.ZERO, acceleration * delta)

	if patrol_pause_timer >= patrol_pause_time:
		change_state(EnemyState.PATROL)
		
# counts amount of time during patrol
func tick_patrolling(delta: float) -> void:
	# executes patrol movement only, state transitions happen with hooks
	patrol(delta)

func tick_chase(delta: float) -> void:
	if chase_target == null:
		change_state(EnemyState.PATROL)
		return

	var to_target := chase_target.global_position - body.global_position
	var dir := to_target.normalized()
	var desired_velocity := dir * patrol_speed * 1.3

	body.velocity = body.velocity.move_toward(
		desired_velocity,
		acceleration * delta
	)
	
# decides what to do when detection area comes in contact with CharacterBody2D
func _on_body_entered(node: Node) -> void:
	if node.is_in_group("player"):
		chase_target = node
		change_state(EnemyState.CHASE)

# decides what to do when detection area loses contact with CharacterBody2D
func _on_body_exited(node: Node) -> void:
	if node == chase_target:
		chase_target = null
		patrol_pause_timer = 0.0
		change_state(EnemyState.PATROL)

# Patrol behavior
func patrol(delta: float) -> void:
	if patrol_points.is_empty():
		return

	var target := patrol_points[patrol_index]
	var to_target := target.global_position - body.global_position
	var distance := to_target.length()

	# checks for reached patrol point
	if distance <= arrive_radius:
		on_patrol_point_reached()
		return

	# Move toward patrol point
	var dir := to_target.normalized()
	var desired_velocity := dir * patrol_speed

	body.velocity = body.velocity.move_toward(
		desired_velocity,
		acceleration * delta
	)

# looks for enemy state to call
func _physics_process(delta: float) -> void:
	match state:
		EnemyState.IDLE:
			tick_idle(delta)
		EnemyState.PATROL:
			tick_patrolling(delta)
		EnemyState.CHASE:
			tick_chase(delta)

	body.move_and_slide()
