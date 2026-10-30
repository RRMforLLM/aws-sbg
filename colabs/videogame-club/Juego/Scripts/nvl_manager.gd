extends Node

func _ready() -> void:
	global_var.actualizacion.connect(listo_act)
	global_var.carga_confirmada()
	#jugador.camara.enabled = false
	
func _on_servidor_coms_act_variables() -> void:
	global_var.obtener_valores()
	var jugador
	for j in get_tree().get_nodes_in_group("jugador"):
		if j.is_multiplayer_authority():
			jugador = j
			break
	jugador.forzar_valores_a_todos()

func listo_act():
	await get_tree().create_timer(0.2).timeout
	#print(global_var.variables)
	if !global_var.partida_empezada: return
	var jugador
	for j in get_tree().get_nodes_in_group("jugador"):
		if j.is_multiplayer_authority():
			jugador = j
			break
	jugador.forzar_valores_a_todos()
