extends StaticBody2D

@export var puntos_necesarios : int
@export var colision : CollisionShape2D
@onready var sprite: Sprite2D = $SnowLandTree
@export var check : Marker2D
@export var id : int = 1
#
@onready var col: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D
#func _ready() -> void:
	#push_warning("La puerta no esta acabada.........")

func _process(delta: float) -> void:
	if global_var.puntos_partida == puntos_necesarios and global_var.puerta_act == id:
		colision.disabled = true
		sprite.material.set_shader_parameter("progress", 0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		global_var.checkpoint = check.global_position
		global_var.puntos_partida = 0
		global_var.puerta_act += 1
		
