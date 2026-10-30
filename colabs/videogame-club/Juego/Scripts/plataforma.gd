extends StaticBody2D

@export_category("puntos")
@export var puntos : bool = true
@export var de : int
@export var a : int
@export var velocidad_linear : Vector2 

@onready var colision: CollisionShape2D = $CollisionShape2D
var jugador 
@onready var label: Label = $HBoxContainer/Label
@onready var sprite: TextureRect = $TextureRect

func _ready() -> void:
	label.text = str(de) + " - " + str(a)
	constant_linear_velocity = velocidad_linear

func _process(delta: float) -> void:
	if !global_var.partida_empezada: return

	for j in get_tree().get_nodes_in_group("jugador"):
		if j.is_multiplayer_authority():
			jugador = j
			break
	if puntos:
		if !(jugador.puntos >= de && jugador.puntos <= a):
			colision.disabled = true
			sprite.hide()
			label.modulate = Color(1.0, 0.0, 0.0, 1.0)
		else:
			colision.disabled = false
			sprite.show()
			label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		label.hide()
		$HBoxContainer/Moneda.hide()
		sprite.modulate = Color(0.914, 1.0, 0.0, 1.0)
