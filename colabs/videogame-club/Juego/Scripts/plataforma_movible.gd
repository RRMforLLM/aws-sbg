extends StaticBody2D

@export var punto_a : Marker2D
@export var punto_b : Marker2D
@export var vel : int
@onready var linea: Line2D = $Line2D

var destino

func _ready() -> void:
	destino = punto_a
	linea.add_point(Vector2.ZERO)
	linea.add_point(Vector2.ZERO)
	linea.set_point_position(0, punto_a.global_position)
	linea.set_point_position(1, punto_b.global_position)
	
func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(destino.global_position, vel * delta)
	
	if global_position.is_equal_approx(punto_a.global_position):
		destino = punto_b
	elif global_position.is_equal_approx(punto_b.global_position):
		destino = punto_a
