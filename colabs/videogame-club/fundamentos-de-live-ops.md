# Fundamentos de Live Ops: Interacción en Tiempo Real con Amazon EC2, Flask y Godot

## Requisitos previos

* Cuenta de AWS activa
* Navegador web moderno
* Godot Engine (versión 4.x) instalado localmente
* Archivo base del juego en Godot preparado para recibir peticiones HTTP

## Prerrequisito adicional

Antes de comenzar, asegúrate de fijar tu consola de AWS en una región específica (ej. `us-east-1` N. Virginia). Todos los recursos deben crearse en la misma región para mantener el orden y evitar costos residuales de recursos huérfanos.

## Pasos

### 1 - Provisionamiento de la instancia EC2

**Desde la consola de AWS (UI)**

* Navega al servicio **EC2**.
* Da clic en **Launch instance** (Lanzar instancia).
* **Name**: `sbg-uach-liveops-server`
* **AMI**: Selecciona **Amazon Linux 2023 AMI** (arquitectura **64-bit (x86)**)
* **Instance type**: `t2.micro` / `t3.micro` (apto para la capa gratuita)
* **Key pair (login)**: Selecciona **Proceed without a key pair** (óptimo para este laboratorio utilizando Instance Connect).

### 2 - Configuración de Redes y Seguridad

**En la sección Network settings**

* Da clic en **Edit**.
* Selecciona **Create security group**.
* **Security group name**: `sbg-liveops-sg`
* **Inbound security group rules**:
* Regla 1: Type `SSH`, Port `22`, Source `Anywhere` (`0.0.0.0/0`)
* Regla 2: Da clic en **Add security group rule**. Type `Custom TCP`, Port `8000`, Source `Anywhere` (`0.0.0.0/0`)

Da clic en **Launch instance** y espera a que el estado cambie a *Running*.

### 3 - Conexión a la instancia e Instalación de Dependencias

* Selecciona tu instancia `sbg-uach-liveops-server`.
* Da clic en **Connect** en la parte superior.
* En la pestaña **EC2 Instance Connect**, da clic en **Connect**.

**Ejecuta los siguientes comandos para instalar Flask:**

```bash
sudo dnf install python3-pip -y
pip3 install flask
```

### 4 - Creación del Servidor Flask (Backend y UI)

**Crea el archivo de la aplicación:**

```bash
nano app.py
```

**Pega el siguiente código fuente:**

```python
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

# Estado inicial exacto basado en variables_juego.json
game_state = {
    "color": "#ffffff",
    "gravedad": 980,
    "maxima_gravedad": 300,
    "nombre": "",
    "puede_mov": True,
    "puede_saltar": True,
    "puntos": 1000,
    "salto": -220,
    "velocidad": 75,
    "vidas": 3
}

html_ui = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: Arial; padding: 20px; background-color: #f4f4f9; }
        .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        input[type="range"] { width: 100%; margin: 10px 0 20px; }
        input[type="color"], input[type="text"], input[type="number"] { width: 100%; padding: 10px; margin: 5px 0 15px; border-radius: 5px; border: 1px solid #ccc; box-sizing: border-box; }
        input[type="checkbox"] { transform: scale(1.5); margin: 10px; }
        button { background: #ff4a4a; color: white; padding: 15px; width: 100%; border: none; border-radius: 5px; font-size: 18px; font-weight: bold; cursor: pointer; }
        .val { font-weight: bold; color: #ff4a4a; }
    </style>
</head>
<body>
    <div class="card">
        <h2>🔥 Panel de Sabotaje 🔥</h2>
        <form action="/update" method="post">
            
            <label>Nombre del Jugador:</label>
            <input type="text" name="nombre" value="{{ state.nombre }}" placeholder="Escribe un nombre...">
            
            <label>Color del Jugador:</label>
            <input type="color" name="color" value="{{ state.color }}">
            
            <label>Puntos base:</label>
            <input type="number" name="puntos" value="{{ state.puntos }}">
            
            <label>Gravedad: <span class="val" id="v_grav">{{ state.gravedad }}</span></label>
            <input type="range" name="gravedad" min="0" max="2500" value="{{ state.gravedad }}" oninput="v_grav.innerText=this.value">
            
            <label>Máxima Gravedad: <span class="val" id="v_maxg">{{ state.maxima_gravedad }}</span></label>
            <input type="range" name="maxima_gravedad" min="50" max="1500" value="{{ state.maxima_gravedad }}" oninput="v_maxg.innerText=this.value">
            
            <label>Fuerza de Salto: <span class="val" id="v_salto">{{ state.salto }}</span></label>
            <input type="range" name="salto" min="-1000" max="-50" value="{{ state.salto }}" oninput="v_salto.innerText=this.value">
            
            <label>Velocidad: <span class="val" id="v_vel">{{ state.velocidad }}</span></label>
            <input type="range" name="velocidad" min="10" max="500" value="{{ state.velocidad }}" oninput="v_vel.innerText=this.value">
            
            <label>Vidas: <span class="val" id="v_vidas">{{ state.vidas }}</span></label>
            <input type="range" name="vidas" min="1" max="10" value="{{ state.vidas }}" oninput="v_vidas.innerText=this.value">
            
            <label><input type="checkbox" name="puede_mov" value="true" {% if state.puede_mov %}checked{% endif %}> Puede Moverse</label><br>
            <label><input type="checkbox" name="puede_saltar" value="true" {% if state.puede_saltar %}checked{% endif %}> Puede Saltar</label><br><br>
            
            <button type="submit">HACKEAR JUEGO</button>
        </form>
    </div>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(html_ui, state=game_state)

@app.route('/update', methods=['POST'])
def update():
    game_state["nombre"] = request.form.get("nombre", game_state["nombre"])
    game_state["color"] = request.form.get("color", game_state["color"])
    game_state["puntos"] = int(request.form.get("puntos", game_state["puntos"]))
    game_state["gravedad"] = int(request.form.get("gravedad", game_state["gravedad"]))
    game_state["maxima_gravedad"] = int(request.form.get("maxima_gravedad", game_state["maxima_gravedad"]))
    game_state["salto"] = int(request.form.get("salto", game_state["salto"]))
    game_state["velocidad"] = int(request.form.get("velocidad", game_state["velocidad"]))
    game_state["vidas"] = int(request.form.get("vidas", game_state["vidas"]))
    game_state["puede_mov"] = "puede_mov" in request.form
    game_state["puede_saltar"] = "puede_saltar" in request.form
    return '<script>window.location.href="/";</script>'

@app.route('/variables_juego.json')
def get_state():
    return jsonify(game_state)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, threaded=True)

```

*(Guarda con `Ctrl+O`, `Enter`, y sal con `Ctrl+X`)*

### 5 - Ejecución del servidor y sincronización

**Inicia el servidor Flask:**

```bash
python3 app.py
```

**Obtén la IP pública y conecta al público:**

* Copia la **Public IPv4 address** de tu instancia en la consola de EC2.
* Genera un código QR o proporciona la URL a la audiencia: `http://TU_IP_PUBLICA:8000`

**Configura el script en Godot (Presentador):**

* En el nodo que controla el juego, asegúrate de tener un `Timer` (0.5s) que ejecute peticiones a la ruta del JSON.

```gdscript
extends Node2D

@onready var http_request = $HTTPRequest
var ec2_ip = "http://TU_IP_PUBLICA:8000/variables_juego.json"

func _on_timer_timeout():
    http_request.request(ec2_ip)

func _on_http_request_request_completed(result, response_code, headers, body):
    if response_code == 200:
        var json = JSON.new()
        json.parse(body.get_string_from_utf8())
        var cloud_data = json.get_data()
        
        $Player.modulate = Color(cloud_data["color"])
        $Player.gravity = cloud_data["gravedad"]
        $Player.max_gravity = cloud_data["maxima_gravedad"]
        $Player.can_move = cloud_data["puede_mov"]
        $Player.can_jump = cloud_data["puede_saltar"]
        $GameManager.score = cloud_data["puntos"]
        $Player.jump_force = cloud_data["salto"]
        $Player.speed = cloud_data["velocidad"]
        $GameManager.lives = cloud_data["vidas"]

```

### 6 - Limpieza de recursos

**Termina la instancia para detener los cargos de cómputo y almacenamiento:**

* En la consola de EC2, selecciona `sbg-uach-liveops-server`.
* Da clic en **Instance state** > **Terminate (delete) instance**.
* Confirma la terminación y espera a que el estado cambie a *Terminated*.
* Navega a **Security Groups** en el panel izquierdo y elimina `sbg-liveops-sg` una vez que la instancia haya sido terminada por completo.

## Recomendaciones de seguridad

* **Exposición de puertos no estándar**
* El puerto 8000 se expuso globalmente (`0.0.0.0/0`) para permitir el acceso del público al panel. En producción, las APIs y paneles de administración deben operar detrás de un Application Load Balancer (ALB) o API Gateway en los puertos estándar 80/443.


* **Validación de Inputs**
* El script de Flask utilizado no contiene validación estricta de inputs (sanitización). En un entorno real, la inyección de datos maliciosos a través del formulario debe bloquearse antes de actualizar el estado del servidor.


* **Terminación de Instancias**
* Termina la instancia EC2 inmediatamente después del evento. Mantener puertos abiertos con software de demostración sin autenticación es un vector crítico de ataque.
