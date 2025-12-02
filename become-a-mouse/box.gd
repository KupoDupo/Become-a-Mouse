extends CharacterBody2D

@export var push_speed: float = 50.0

var _push_dir: Vector2 = Vector2.ZERO

func add_push(dir: Vector2) -> void:
	# Called by the player when they run into the box
	if dir != Vector2.ZERO:
		_push_dir = dir.normalized()

func _physics_process(delta: float) -> void:
	if _push_dir != Vector2.ZERO:
		velocity = _push_dir * push_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Reset each frame so it only moves while being pushed
	_push_dir = Vector2.ZERO
