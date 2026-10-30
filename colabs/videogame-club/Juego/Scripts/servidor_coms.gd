extends Node

@export var url : String
@onready var arch_ubi : String = global_var.archivo

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var carga: CanvasLayer = $carga

signal act_variables

func _ready() -> void:
	global_var.archivo = arch_ubi
	print(arch_ubi)
	#descargar_archivos()
	carga.hide()

func descargar_archivos():
	carga.show()
	anim.play("cargando")
	http_request.request(url)
	print("Descargando archivos")
	await http_request.request_completed
	anim.play("ok")

@warning_ignore("unused_parameter")
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var file = FileAccess.open(arch_ubi, FileAccess.WRITE)
		if file:
			file.store_buffer(body) 
			file.close()
			print("Archivo guardado:", arch_ubi)
			await get_tree().create_timer(1).timeout 
			act_variables.emit() 
			
		else:
			print("No se pudo guardar el archivo:", arch_ubi)
	else:
		OS.alert("Error de conexion.\n"+"Código: " + str(response_code),"Error de conexion")
		print("Error al descargar", "Código:", response_code)


func _on_refresh_timeout() -> void:
	descargar_archivos()
