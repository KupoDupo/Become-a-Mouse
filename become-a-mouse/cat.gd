extends CharacterBody2D

@export var move_speed: float = 60.0
@export var min_move_time: float = 0.8
@export var max_move_time: float = 2.0
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 2.0

@export var player: Node2D
@export var chase_speed: float = 120.0

@export var attention_gain_in_zone: float = 10.0
@export var attention_gain_facing_max: float = 20.0
@export var attention_loss_outside: float = 5.0
@export var attention_chase_threshold: float = 100.0
@export var attention_drop_chase_threshold: float = 20.0

@export var ui: attention_ui
@export var GameOver: CanvasLayer

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cat_sound_player: AudioStreamPlayer = $CatSoundPlayer

enum State { IDLE, WALK, CHASE }
var state: State = State.IDLE
var state_time_left: float = 0.0
var direction: Vector2 = Vector2.ZERO

var attention: float = 0.0
var player_in_light_zone: bool = false
var game_has_ended: bool = false
var player_in_vision: bool = false


func _ready() -> void:
	randomize()

	if player == null:
		player = get_tree().get_node("Player") as Node2D
		if player == null:
			push_error("Cat: No player assigned — chasing will be broken.")

	anim.animation = "walk"
	_enter_idle_state()


func _physics_process(delta: float) -> void:
	if game_has_ended:
		velocity = Vector2.ZERO
		move_and_slide()
		if anim:
			anim.play("idle")
		return

	_update_attention(delta)

	if ui:
		ui.set_attention(attention)

	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			state_time_left -= delta

			if _should_start_chase():
				state = State.CHASE
				if cat_sound_player and not cat_sound_player.playing:
					cat_sound_player.play()
			elif state_time_left <= 0.0:
				_enter_walk_state()

		State.WALK:
			if _should_start_chase():
				state = State.CHASE
				if cat_sound_player and not cat_sound_player.playing:
					cat_sound_player.play()
			else:
				state_time_left -= delta
				velocity = direction * move_speed
				move_and_slide()

				if state_time_left <= 0.0:
					_enter_idle_state()

		State.CHASE:
			_chase_player(delta)

	_update_animation()


func _enter_idle_state() -> void:
	state = State.IDLE
	state_time_left = randf_range(min_idle_time, max_idle_time)
	direction = Vector2.ZERO
	
	if cat_sound_player and cat_sound_player.playing:
		cat_sound_player.stop()


func _enter_walk_state() -> void:
	state = State.WALK
	state_time_left = randf_range(min_move_time, max_move_time)
	var angle := randf_range(0.0, TAU)
	direction = Vector2.RIGHT.rotated(angle).normalized()


func _chase_player(delta: float) -> void:

	if player == null or not player_in_light_zone:
		_enter_idle_state()
		return

	var to_player: Vector2 = (player.global_position - global_position).normalized()
	velocity = to_player * chase_speed
	move_and_slide()

	if attention <= attention_drop_chase_threshold and not player_in_vision:
		_enter_idle_state()


func _should_start_chase() -> bool:
	return attention >= attention_chase_threshold or player_in_vision


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
			var cos_threshold: float = cos(deg_to_rad(45.0))

			if dot >= cos_threshold:
				var t: float = clamp((400.0 - dist) / (400.0 - 50.0), 0.0, 1.0)
				delta_attention += 20.0 * t * delta

	if player_in_vision:
		delta_attention += attention_gain_facing_max * 1.5 * delta

	if not player_in_light_zone and not player_in_vision:
		delta_attention -= attention_loss_outside * delta

	attention = clamp(attention + delta_attention, 0.0, 100.0)


func _update_animation() -> void:
	if anim == null:
		return

	if velocity.x != 0.0:
		anim.flip_h = velocity.x < 0.0

	if velocity.length() == 0.0:
		anim.animation = "walk"
		anim.stop()
		anim.frame = 0
	elif not anim.is_playing():
		anim.play()


func _game_over_call() -> void:
	if game_has_ended:
		return

	game_has_ended = true

	if GameOver and GameOver.has_method("game_over"):
		GameOver.game_over()


func set_player_in_light_zone(in_zone: bool) -> void:
	player_in_light_zone = in_zone


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not game_has_ended:
		_game_over_call()


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_vision = true


func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_vision = false
