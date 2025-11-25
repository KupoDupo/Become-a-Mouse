extends Area2D

@export var darkness_node: CanvasItem    # assign Darkness (ColorRect) here in inspector
@export var cat: Node                    # assign your Cat node (with set_player_in_light_zone) here

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if _is_player(body):
		_set_darkness_strength(0.0)
		if cat != null and cat.has_method("set_player_in_light_zone"):
			cat.set_player_in_light_zone(true)


func _on_body_exited(body: Node) -> void:
	if _is_player(body):
		_set_darkness_strength(1.0)
		if cat != null and cat.has_method("set_player_in_light_zone"):
			cat.set_player_in_light_zone(false)



func _is_player(body: Node) -> bool:
	# Simplest check: exact node name
	return body.name == "Player"


func _set_darkness_strength(value: float) -> void:
	if darkness_node == null:
		print("No darkness_node assigned!")
		return

	var mat := darkness_node.material
	if mat is ShaderMaterial:
		(mat as ShaderMaterial).set_shader_parameter("darkness_strength", value)
		print("Set darkness_strength to ", value)
	else:
		print("darkness_node.material is not a ShaderMaterial!")
