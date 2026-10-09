extends Area2D

@onready var jugador := get_tree().get_first_node_in_group("jugador")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		get_tree().reload_current_scene()
