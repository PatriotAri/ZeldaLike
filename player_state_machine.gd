extends CharacterBody2D

enum PlayerState {IDLE, WALK, RUN}

var state: PlayerState = PlayerState.IDLE

@export var player_walk_speed := 50.0
@export var player_run_speed := 75.0
@export var player_health := 10.0
##temporarily set spawn point to top left (0,0) until screen system is established
@export var player_position := Vector2.ZERO

func _physics_process(delta: float) -> void:
	player_input()
	player_update()
	player_move()
