extends Node2D

@export var required_key_id: String = "maze_door"

@onready var blocker: StaticBody2D = $Blocker
@onready var trigger: Area2D = $Trigger
@onready var sprite: Sprite2D = $Blocker/MazeLock
@onready var blocker_shape: CollisionShape2D = $Blocker/CollisionShape2D
@onready var door: ColorRect = $Blocker/ColorRect

var is_open := false

func _ready() -> void:
	trigger.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_open:
		return

	if body.name == "Player":
		if body.has_method("has_key_for") and body.has_key_for(required_key_id):
			body.consume_key()
			open_door()


func open_door() -> void:
	is_open = true

	# Turn off collisioonn
	if blocker_shape:
		blocker_shape.set_deferred("disabled", true)

	# remove blocker from collision layer/mask
	blocker.set_deferred("collision_layer", 0)
	blocker.set_deferred("collision_mask", 0)

	if sprite:
		sprite.hide()
		door.hide()
