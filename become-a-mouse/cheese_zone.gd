extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var ui = get_tree().get_root().get_node("Maze/GameOver")
		if ui and ui.has_method("game_win"):
			ui.game_win()
