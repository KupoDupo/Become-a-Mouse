extends CanvasLayer
class_name attention_ui

@export var attention_bar: ColorRect

func _on_value_changed(v: int) -> void:
	var t: float = clampf(float(v) / 100.0, 0.0, 1.0)
	var new_size: Vector2 = attention_bar.size
	new_size.x = 313 * t
	attention_bar.size = new_size
	var green: Color = Color8(0, 255, 0)
	var red: Color = Color8(255, 0, 0)
	attention_bar.color = green.lerp(red, t)
