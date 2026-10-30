extends Node

var variables 

@onready var carpeta : String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Servidor_taller"
@onready var archivo : String = carpeta + "/variables_juego.json" 
var puntos_partida : int = 0
var puerta_act : int = 1
var partida_empezada : bool = false
var checkpoint := Vector2(48,120)

signal actualizacion

func _ready() -> void:
	await crear_directorio(carpeta, "carpeta del juego")
	await crear_archivo(archivo)
	obtener_valores()

func obtener_valores():
	var file = FileAccess.open(archivo,FileAccess.READ)
	if !file:
		await get_tree().create_timer(0.2).timeout
		obtener_valores()
		return
	var json = file.get_as_text()
	variables = JSON.parse_string(json)

	print(variables)
	
	file.close()
	actualizacion.emit()
	
func crear_directorio(ruta: String, descripcion: String = ""):
	var base_dir := DirAccess.open(ruta.get_base_dir())
	
	if base_dir and base_dir.dir_exists(ruta):
		print("Ya existe: ", descripcion)
		return
		
	else:
		base_dir.make_dir(ruta)
		print("Carpeta creada:", descripcion, "->", ruta)
		
func crear_archivo(ruta: String):
	if FileAccess.file_exists(ruta):
		print("El archivo ya existe")
		return
		
	else:
		var estructura := {
			"velocidad": 75,
			"salto": -220,
			"gravedad": 980,
			"puntos": 0,
			"vidas": 3,
			"puede_saltar": true,
			"puede_mov": true,
			"nombre": "tilin",
			"color": "#ffffff",
			"maxima_gravedad": 300
		}
		
		var file := FileAccess.open(ruta, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(estructura, "\t"))  # "\t" = indentado bonito
			file.close()
			print("Archivo JSON creado en:", ruta)
		
	#arch_creado.emit()

func carga_confirmada():
	actualizacion.emit()
	print("hola")
