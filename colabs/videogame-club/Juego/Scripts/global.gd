extends Node

var jugador_vel : float
var jugador_salto : float
var jugador_gravedad : float
var jugador_pts : int
var jugador_vidas : int
var jugador_saltar : bool
var jugador_moverse : bool
var jugador_nombre : String
var jugador_color : Color
var jugador_max_gravedad : float

var carpeta : String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Servidor_taller"
var archivo : String

func _ready() -> void:
	crear_directorio(carpeta, "carpeta del juego")
	print(archivo)
	await get_tree().process_frame
	crear_archivo(archivo)

func obtener_valores():
	var file = FileAccess.open(archivo,FileAccess.READ)
	var json = file.get_as_text()
	var datos = JSON.parse_string(json)
	
	jugador_vel = datos["velocidad"]
	jugador_salto = datos["salto"]
	jugador_gravedad = datos["gravedad"]
	jugador_pts = datos["puntos"]
	jugador_vidas = datos["vidas"]
	jugador_saltar = datos["puede_saltar"]
	jugador_moverse = datos["puede_mov"]
	jugador_nombre = datos["nombre"]
	jugador_color = datos["color"]
	jugador_max_gravedad = datos["maxima_gravedad"]
	
	file.close()

func crear_directorio(ruta: String, descripcion: String = ""):
	var base_dir := DirAccess.open(ruta.get_base_dir())
	
	if base_dir and not base_dir.dir_exists(ruta):
		base_dir.make_dir(ruta)
		print("Carpeta creada:", descripcion, "->", ruta)
	else:
		print("Ya existe: ", descripcion)

func crear_archivo(ruta: String):
	if not FileAccess.file_exists(ruta):
		var estructura := {
			"velocidad": 75,
			"salto": -220,
			"gravedad": 980,
			"puntos": 0,
			"vidas": 3,
			"puede_saltar": true,
			"puede_mov": true,
			"nombre": "",
			"color": "#ffffff",
			"maxima_gravedad": 300
		}
		
		var file := FileAccess.open(ruta, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(estructura, "\t"))  # "\t" = indentado bonito
			file.close()
			print("Archivo JSON creado en:", ruta)
		
	else:
		print("El archivo ya existe")
	
