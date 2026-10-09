# Fundamentos de Live Ops: Balanceo de Juegos en la Nube con Amazon S3 y Godot

## El Problema

Cuando exportas tu juego (el `.exe` o HTML5) para un Game Jam, los valores de velocidad, daño y gravedad quedan congelados. Si te das cuenta de que el jefe final es invencible, tienes que re-exportar todo el juego y pedirle a la gente que lo vuelva a descargar.

## La Solución (AWS)

Vamos a subir un archivo de configuración a la nube (Amazon S3). Al abrir el juego en Godot, este se conectará a AWS, descargará los valores más recientes y los aplicará al instante.

## Requisitos previos

* Cuenta de AWS activa.
* Godot Engine (versión 4.x) instalado.
* Un proyecto vacío en Godot.

---

## Pasos en AWS (La Nube)

### 1 - Crear tu archivo de parcheo (Local)

Abre el Bloc de Notas (Notepad) en tu computadora, pega el siguiente texto y guárdalo en tu escritorio como `patch.json`:

```json
{
  "player_speed": 850,
  "gravity": 12,
  "double_jump_enabled": true,
  "message_of_the_day": "¡Bienvenidos al servidor de prueba AWS!"
}

```

### 2 - Crear tu almacenamiento en la nube (S3)

* En la consola de AWS, busca **S3** y entra al servicio.
* Da clic en **Create bucket**.
* **Bucket name:** Escribe un nombre único (ej. `sbg-godot-tu-nombre-123`). *Cópialo, lo vas a necesitar.*
* **Block Public Access settings for this bucket:** Desmarca la casilla que dice *Block all public access*.
* Marca la casilla de advertencia que aparece abajo reconociendo que el bucket será público.
* Ve hasta el final y da clic en **Create bucket**.

### 3 - Dar permisos de lectura

Por seguridad, AWS no deja que nadie lea los archivos hasta que lo permitas explícitamente.

* Da clic en el nombre de tu nuevo bucket.
* Ve a la pestaña **Permissions** (Permisos).
* Baja hasta **Bucket policy** y da clic en **Edit**.
* Pega el siguiente código, asegurándote de cambiar `TU-NOMBRE-DE-BUCKET` por el nombre real de tu bucket:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::TU-NOMBRE-DE-BUCKET/*"
        }
    ]
}

```

* Da clic en **Save changes**.

### 4 - Subir tu archivo de balanceo

* Ve a la pestaña **Objects** y da clic en **Upload**.
* Da clic en **Add files** y selecciona el archivo `patch.json` de tu escritorio.
* Da clic en **Upload** (abajo) y luego en **Close**.
* Da clic sobre tu archivo `patch.json` en la lista.
* Copia la **Object URL** que aparece en las propiedades (se ve algo así como `[https://sbg-godot...s3.amazonaws.com/patch.json](https://sbg-godot...s3.amazonaws.com/patch.json)`).

---

## Pasos en Godot (El Juego)

### 5 - Conectar Godot a AWS

* Abre Godot 4 y crea un proyecto nuevo.
* Crea una escena **2D Scene** (Node2D).
* Adjunta un nuevo script (ícono de pergamino) al Node2D.
* Borra todo el código que trae por defecto y pega este:

```gdscript
extends Node2D

# Creamos el nodo para hacer peticiones a internet
var http_request = HTTPRequest.new()

func _ready():
	# 1. Agregamos el nodo al juego
	add_child(http_request)
	
	# 2. Le decimos qué hacer cuando termine de descargar
	http_request.request_completed.connect(_on_request_completed)
	
	print("Conectando a AWS S3...")
	
	# 3. ¡PEGAR AQUÍ TU URL DE S3!
	var aws_url = "PEGAR_TU_OBJECT_URL_AQUI"
	http_request.request(aws_url)

# Esta función se ejecuta cuando AWS nos responde
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var cloud_data = json.get_data()
		
		print("--- ¡DATOS RECIBIDOS DESDE AWS! ---")
		print("Velocidad del Jugador: ", cloud_data["player_speed"])
		print("Mensaje del día: ", cloud_data["message_of_the_day"])
		print("Doble salto activado: ", cloud_data["double_jump_enabled"])
	else:
		print("Error al conectar con la nube. Código: ", response_code)

```

### 6 - ¡La Magia del Live Ops!

* Pega tu **Object URL** de S3 en la variable `aws_url` del código.
* Da clic en **Play** (icono de reproducir arriba a la derecha). Godot te pedirá guardar la escena, guárdala como `main.tscn`.
* **¡Mira la consola de salida abajo!** Verás los datos descargados directamente desde tu infraestructura en AWS.
* **Prueba Final:** Ve a AWS S3, cambia el mensaje en tu `patch.json`, vuelve a subirlo sobrescribiendo el anterior. Dale Play a Godot otra vez. ¡Tus variables de juego cambiaron sin tocar una sola línea de código en Godot!

---

## Limpieza de recursos

Para no dejar basura en tu cuenta:

* En la consola de AWS, ve a tu bucket de S3.
* Selecciona `patch.json` y bórralo.
* Regresa a la lista de buckets, selecciona tu bucket y da clic en **Delete**. AWS te pedirá escribir el nombre del bucket para confirmar.
