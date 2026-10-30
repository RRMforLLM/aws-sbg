extends Node2D

@export var dialogo : String 

@onready var burbuja: PanelContainer = $burbuja
@onready var txt: Label = $burbuja/Label

var jugador_cerca: bool = false

func _ready() -> void:
	burbuja.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugador_cerca = true
		var vars = {
				"nombre": global_var.variables["nombre"],
				"puntos": str(global_var.variables["puntos"])
			}
			
		var texto_final = dialogo.format(vars)
		burbuja.mostrar_texto(texto_final)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugador_cerca = false
		burbuja.hide()
		txt.text = ""
