extends CharacterBody2D

@export var move_speed: float = 60.0          # how fast the cat walks
@export var min_move_time: float = 0.8        # min seconds walking
@export var max_move_time: float = 2.0        # max seconds walking
@export var min_idle_time: float = 0.5        # min seconds stopped
@export var max_idle_time: float = 2.0        # max seconds stopped

enum State { IDLE, WALK }
var state: State = State.IDLE
var state_time_left: float = 0.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	randomize()
	_enter_idle_state()

func _physics_process(delta: float) -> void:
	state_time_left -= delta

	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			if state_time_left <= 0.0:
				_enter_walk_state()

		State.WALK:
			velocity = direction * move_speed
			move_and_slide()
			if state_time_left <= 0.0:
				_enter_idle_state()


func _enter_idle_state() -> void:
	state = State.IDLE
	state_time_left = randf_range(min_idle_time, max_idle_time)


func _enter_walk_state() -> void:
	state = State.WALK
	state_time_left = randf_range(min_move_time, max_move_time)

	# pick a random direction
	var angle := randf_range(0.0, TAU)
	direction = Vector2.RIGHT.rotated(angle).normalized()
