extends CharacterBody2D

var held_key_id: String = "" # empty = not holding anything

@export var speed := 150.0
@onready var darkness_mat = get_tree().get_root().get_node("Maze/CanvasLayer/ColorRect").material
@onready var camera = get_viewport().get_camera_2d()
@onready var anim: AnimatedSprite2D = $MouseMove

@onready var held_item: Sprite2D = $HeldItem
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

func _ready() -> void:
	held_item.hide()

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
	_update_animation()
	move_and_slide()


func _update_animation() -> void:
	if anim == null:
		return
	if velocity.length() == 0.0:
		anim.stop()
		anim.frame = 0
		if audio_player.playing:
			audio_player.stop()
		return
	
	if not audio_player.playing:
		audio_player.play()
	if velocity.x != 0.0:
		anim.play("walk_side")
		anim.flip_h = velocity.x < 0.0
	else:
		if velocity.y > 0.0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")

# KEY INTERACTION
func can_pickup_item() -> bool:
	return held_key_id == ""

func pick_up_key(key_id: String, icon_tex: Texture2D) -> void:
	held_key_id = key_id
	held_item.texture = icon_tex
	held_item.show()

func has_key_for(door_key_id: String) -> bool:
	return held_key_id == door_key_id

func consume_key() -> void:
	held_key_id = ""
	held_item.hide()
