extends Node2D

@export var key_id: String = "maze_door"  # set which key goes to which door (if we want to do that)

@onready var pickup_area: Area2D = $PickupArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _ready() -> void:
	pickup_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only react to the Player
	if body.name == "Player":
		# Only pick up if player has room
		if body.has_method("can_pickup_item") and body.can_pickup_item():
			body.pick_up_key(key_id, sprite.texture)
			pickup_sound.play()
			pickup_area.body_entered.disconnect(_on_body_entered)
			pickup_sound.finished.connect(queue_free, CONNECT_ONE_SHOT)
			sprite.visible = false
			pickup_area.set_deferred("monitoring", false)
			#queue_free()  # remove the key from the world
