extends CanvasLayer
class_name attention_ui

@export var attention_bar: Panel

func set_attention(v: int) -> void:
	var t: float = clampf(float(v) / 100.0, 0.0, 1.0)
	var new_size: Vector2 = attention_bar.size
	new_size.x = 313 * t
	attention_bar.size = new_size
	var stylebox := attention_bar.get_theme_stylebox("panel") as StyleBoxFlat
	var green: Color = Color8(0, 255, 0)
	var red: Color = Color8(255, 0, 0)
	stylebox.bg_color = green.lerp(red, t)
