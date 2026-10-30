extends CharacterBody2D

var dir : float

#Variables modificables por el servidor
var velocidad : float 
var salto : float 
var gravedad : float 
var puede_saltar : bool
var puede_mov : bool 
var nombre : String
var color : Color = "#ffffff"
var vidas : int
var puntos : int
var max_gravedad = 300

var modo_dios : bool = false
var dir2

@onready var sprite: Sprite2D = $ZanahoriaPj
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var pts_lbl: Label = $hud/puntos/pts
@onready var vidas_lbl: Label = $hud/vidas_count/TextureRect/vidas
@onready var camara = $Camera2D
@onready var hud: CanvasLayer = $hud
@onready var multi: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	print(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		#set_physics_process(false)
		#set_process_input(false)
		collision_layer = 0
		collision_mask = 0
		sprite.modulate.a = 0.7 
		hud.hide()
	else:
		camara.make_current()
		
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	sprite.material.set_shader_parameter("color_nuevo", color)
	pts_lbl.text = ": " + str(puntos)
	vidas_lbl.text = "x" + str(vidas)
	velocity.y = clampf(velocity.y, salto, max_gravedad)
	if modo_dios:
		dir2 = Input.get_vector("mov_izq","mov_der","arriba","abajo")
		velocity = dir2 * velocidad
	else:
		if not is_on_floor():
			velocity.y += gravedad * delta
		
		if Input.is_action_just_pressed("salto") and is_on_floor() and puede_saltar:
			velocity.y = salto
			
		dir = Input.get_axis("mov_izq", "mov_der")
		if !puede_mov: return
		if dir:
			velocity.x = dir * velocidad
		else:
			velocity.x = 0

	move_and_slide()
	animaciones()
	
func animaciones():
	if velocity.x != 0:
		anim.play("caminar")
	else:
		anim.play("idle")
	
	if dir == -1:
		sprite.flip_h = true
		
	elif dir == 1:
		sprite.flip_h = false

func act_valores():
	print("Actualizando valores")
	puntos = global_var.variables["puntos"]
	nombre = global_var.variables["nombre"]
	puede_saltar = global_var.variables["puede_saltar"]
	puede_mov = global_var.variables["puede_mov"]
	vidas = global_var.variables["vidas"]
	color = global_var.variables["color"]
	gravedad = global_var.variables["gravedad"]
	velocidad = global_var.variables["velocidad"]
	salto = global_var.variables["salto"]
	max_gravedad = global_var.variables["maxima_gravedad"]

@rpc("any_peer", "call_remote", "reliable")
func recibir_valores_del_host(diccionario_del_host: Dictionary):
	var id_remitente = multiplayer.get_remote_sender_id()
	
	if id_remitente != 1:
		print("Intento de trampa bloqueado del jugador: ", id_remitente)
		return

	global_var.variables = diccionario_del_host
	act_valores()

func forzar_valores_a_todos():
	if multiplayer.is_server():
		act_valores()
		rpc("recibir_valores_del_host", global_var.variables)

func morir():
	print("morir")
	process_mode = Node.PROCESS_MODE_DISABLED
	pantalla_muerte.a.show()
	global_var.variables["vidas"] -= 1
	global_var.variables["puntos"] = 0
	global_var.puntos_partida = 0
	
