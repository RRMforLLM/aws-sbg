extends Node

@onready var mundo_nuevo = preload("res://Escenas/mundo.tscn")
@onready var a: ColorRect = $pantalla_muerte

func _ready() -> void:
	a.hide()

func _on_button_pressed() -> void:
	#print("holaaa")
	var jugador 
	for j in get_tree().get_nodes_in_group("jugador"):
		if j.is_multiplayer_authority():
			jugador = j
			break
			
	var mundo = get_tree().get_first_node_in_group("mundo")
	mundo.queue_free()
	await get_tree().process_frame
	a.hide()
	await get_tree().process_frame
	jugador.global_position = global_var.checkpoint
	await get_tree().process_frame
	jugador.process_mode = Node.PROCESS_MODE_PAUSABLE
	await get_tree().process_frame
	var inst = mundo_nuevo.instantiate()
	await get_tree().process_frame
	inst.add_to_group("mundo")
	await get_tree().process_frame
	get_node("/root/nivel_1").add_child(inst)
	
	jugador.act_valores()
	
