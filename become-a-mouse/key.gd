extends Node2D

@export var key_id: String = "maze_door"  # set which key goes to which door (if we want to do that)

@onready var pickup_area: Area2D = $PickupArea
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	pickup_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only react to the Player
	if body.name == "Player":
		# Only pick up if player has room
		if body.has_method("can_pickup_item") and body.can_pickup_item():
			body.pick_up_key(key_id, sprite.texture)
			queue_free()  # remove the key from the world
