extends Node

func _ready() -> void:
	global_var.obtener_valores()
	
func _on_servidor_coms_act_variables() -> void:
	global_var.obtener_valores()
