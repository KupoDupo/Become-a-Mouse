extends CanvasLayer

@onready var label: Label = $Label
@export var game_over_sound: AudioStreamPlayer2D
@export var game_win_sound: AudioStreamPlayer2D

func _ready():
	self.hide()

func _show_with_text(text: String) -> void:
	label.text = text
	get_tree().paused = true
	self.show()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func game_over():
	game_over_sound.play()
	_show_with_text("The cat got you!\nRetry to try again.")

func game_win():
	game_win_sound.play()
	_show_with_text("You got to the cheese!\n:)")
