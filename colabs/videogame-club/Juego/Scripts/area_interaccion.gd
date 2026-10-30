extends Area2D

@export var camara: Camera2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		body.camara.enabled = false
		camara.enabled = true
		body.hud.hide()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		camara.enabled = false
		body.camara.enabled = true
		body.hud.show()
		
		
