extends CharacterBody2D

@export var speed := 150.0
@onready var darkness_mat = get_tree().get_root().get_node("Maze/CanvasLayer/ColorRect").material
@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	# Player is at center of screen if Camera2D follows
	var screen_center = get_viewport().get_visible_rect().size / 2

	# Update shader
	darkness_mat.set_shader_parameter("player_pos", screen_center)

	# Update screen size
	darkness_mat.set_shader_parameter("screen_size", get_viewport().get_visible_rect().size)
	
func _physics_process(delta):
	var direction = Vector2.ZERO

	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()
