extends CharacterBody2D

var dir : float

#Variables modificables por el servidor
var velocidad : float = 75
var salto : float = -220
var gravedad : float = 980
var puede_saltar : bool
var puede_mov : bool 
var nombre : String
var color : Color
var vidas : int
var puntos : int
var max_gravedad = 300

@onready var sprite: Sprite2D = $ZanahoriaPj
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var pts_lbl: Label = $hud/puntos/pts
@onready var vidas_lbl: Label = $hud/TextureRect/vidas


func _physics_process(delta: float) -> void:
	#act_valores()
	pts_lbl.text = ": " + str(puntos)
	vidas_lbl.text = "x" + str(vidas)
	velocity.y = clampf(velocity.y, salto, max_gravedad)
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = salto

	dir = Input.get_axis("mov_izq", "mov_der")
	if dir:
		velocity.x = dir * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

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
	puntos = global_var.jugador_pts
	nombre = global_var.jugador_nombre
	puede_saltar = global_var.jugador_saltar
	puede_mov = global_var.jugador_moverse
	vidas = global_var.jugador_vidas
	color = global_var.jugador_color
	gravedad = global_var.jugador_gravedad
	velocidad = global_var.jugador_vel
	salto = global_var.jugador_salto
	max_gravedad = global_var.jugador_max_gravedad
