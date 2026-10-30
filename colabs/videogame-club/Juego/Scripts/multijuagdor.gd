extends Node

const PORT = 8080
var peer = ENetMultiplayerPeer.new()
@onready var player_scene: PackedScene = preload("res://Escenas/Personaje.tscn")
@onready var ip_join: LineEdit = $CanvasLayer/ip_join
@onready var nombre: LineEdit = $CanvasLayer/nombre
@onready var ip: Label = $CanvasLayer/ip

func _ready() -> void:
	ip.text = str(obtener_ip_local())

func host_game():
	peer.create_server(PORT,32)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player(multiplayer.get_unique_id())
	global_var.partida_empezada = true
	$"..".listo_act()
	global_var.variables["nombre"] = nombre.text

func join_game(ip: String):
	if not multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		print("Ya hay una conexión de red activa.")
		return
		
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	$"..".listo_act()
	$CanvasLayer.hide()
	global_var.variables["nombre"] = nombre.text

func _on_player_connected(id):
	_add_player(id)

func _add_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	global_var.variables["nombre"] = nombre.text
	player.set_multiplayer_authority(id)
	player.get_node("MultiplayerSynchronizer").set_multiplayer_authority(id)
	player.add_to_group("jugador")
	$"../jugadores".add_child(player)
	player.forzar_valores_a_todos()
	

func obtener_ip_local():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") or ip.begins_with("10."):
			return ip
	return "IP no encontrada"

func _on_button_pressed() -> void:
	join_game(ip_join.text)

func _on_button_2_pressed() -> void:
	host_game()
	$CanvasLayer.hide()
