extends CharacterBody2D

@export var move_speed: float = 60.0
@export var min_move_time: float = 0.8
@export var max_move_time: float = 2.0
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 2.0

@export var player: Node2D                    # assign Player here OR put Player in "player" group
@export var chase_speed: float = 120.0

@export var attention_gain_in_zone: float = 10.0
@export var attention_gain_facing_max: float = 20.0
@export var attention_loss_outside: float = 5.0
@export var attention_chase_threshold: float = 100.0
@export var attention_drop_chase_threshold: float = 20.0
@export var facing_angle_threshold_deg: float = 45.0
@export var facing_effect_max_range: float = 400.0
@export var facing_effect_min_range: float = 50.0
@export var ui: attention_ui
@export var GameOver: CanvasLayer

enum State { IDLE, WALK, CHASE }
var state: State = State.IDLE
var state_time_left: float = 0.0
var direction: Vector2 = Vector2.ZERO

var attention: float = 0.0
var player_in_light_zone: bool = false
var game_has_ended: bool;

func _ready() -> void:
	randomize()

	# If you forgot to assign player in Inspector, try to find it via group
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			push_error("Cat: No player assigned and no node in group 'player' — chasing will be broken.")

	_enter_idle_state()

	#if ui:
		#ui.set_attention(attention)
func _physics_process(delta: float) -> void:
	if game_has_ended:
		return
	
	_update_attention(delta)

	if ui:
		ui.set_attention(attention)
	
	if attention >= 100.0:
		_game_over_call();
		return
	
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			state_time_left -= delta
			if _should_start_chase():
				state = State.CHASE
			elif state_time_left <= 0.0:
				_enter_walk_state()

		State.WALK:
			if _should_start_chase():
				state = State.CHASE
			else:
				state_time_left -= delta
				velocity = direction * move_speed
				move_and_slide()
				if state_time_left <= 0.0:
					_enter_idle_state()

		State.CHASE:
			# 🚨 NEW: if player leaves the light zone, stop chasing immediately
			if not player_in_light_zone:
				_enter_idle_state()
			else:
				_chase_player(delta)


func _enter_idle_state() -> void:
	state = State.IDLE
	state_time_left = randf_range(min_idle_time, max_idle_time)


func _enter_walk_state() -> void:
	state = State.WALK
	state_time_left = randf_range(min_move_time, max_move_time)
	var angle := randf_range(0.0, TAU)
	direction = Vector2.RIGHT.rotated(angle).normalized()


func _chase_player(delta: float) -> void:
	if player == null:
		_enter_idle_state()
		return

	var to_player: Vector2 = player.global_position - global_position

	if to_player == Vector2.ZERO:
		velocity = Vector2.ZERO
	else:
		direction = to_player.normalized()
		velocity = direction * chase_speed

	move_and_slide()

	if not player_in_light_zone and attention <= attention_drop_chase_threshold:
		_enter_idle_state()


func _should_start_chase() -> bool:
	return attention >= attention_chase_threshold


func _update_attention(delta: float) -> void:
	var delta_attention: float = 0.0

	if player_in_light_zone and player != null:
		delta_attention += attention_gain_in_zone * delta

		var to_player: Vector2 = player.global_position - global_position
		var dist: float = to_player.length()

		if dist > 0.0:
			var dir_to_player: Vector2 = to_player / dist
			var facing: Vector2 = direction
			if facing.length() == 0.0:
				facing = dir_to_player

			facing = facing.normalized()
			var dot: float = facing.dot(dir_to_player)
			var cos_threshold: float = cos(deg_to_rad(facing_angle_threshold_deg))

			if dot >= cos_threshold:
				var max_r := facing_effect_max_range
				var min_r := facing_effect_min_range
				if max_r > min_r:
					var t: float = clamp((max_r - dist) / (max_r - min_r), 0.0, 1.0)
					delta_attention += attention_gain_facing_max * t * delta
	else:
		delta_attention -= attention_loss_outside * delta

	attention = clamp(attention + delta_attention, 0.0, 100.0)
	
func _game_over_call() -> void:
	if game_has_ended:
		return
	
	game_has_ended = true;
	
	if GameOver:
		if GameOver.has_method("game_over"):
			GameOver.game_over();
		else:
			push_warning("Game Over not found")

func set_player_in_light_zone(in_zone: bool) -> void:
	player_in_light_zone = in_zone
