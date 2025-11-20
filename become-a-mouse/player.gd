extends CharacterBody2D

@export var speed := 150.0
@onready var darkness_mat = get_tree().get_root().get_node("Maze/CanvasLayer/ColorRect").material
@onready var camera = get_viewport().get_camera_2d()

# Find screen center to update shader and move it w/player for vision blinding
func _process(delta):
	var screen_center = get_viewport().get_visible_rect().size / 2
	darkness_mat.set_shader_parameter("player_pos", screen_center)
	darkness_mat.set_shader_parameter("screen_size", get_viewport().get_visible_rect().size)

# Player movement
func _physics_process(delta):
	var direction = Vector2.ZERO
		
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()




#
#
#@export var ui: attention_ui
#var numidk = 0.0
#numidk += 0.2
#
#var field = clampi(numidk, 0.0, 100.0)
#if ui:
	#ui.set_attention(field)
