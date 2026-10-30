# Fundamentos de Serverless: AWS Lambda y API Gateway

## Contexto de la Industria

En septiembre provisionamos un servidor EC2 con Apache. Ese servidor cobra por cada segundo que está encendido, reciba tráfico o no. En la industria moderna, los microservicios utilizan arquitecturas *serverless* (sin servidor). El código solo se ejecuta cuando hay una petición, reduciendo los costos inactivos a cero y eliminando la necesidad de administrar sistemas operativos.

## Requisitos previos

* Cuenta de AWS activa.
* Navegador web moderno.

## Prerrequisito adicional

Asegúrate de fijar tu consola de AWS en la región `us-east-1` (N. Virginia).

## Pasos

### 1 - Creación de la función Lambda

**Desde la consola de AWS (UI)**

* Navega al servicio **Lambda**.
* Da clic en **Create Function**.
* Selecciona **Author from scratch**.
* **Function name**: `sbg-uach-api`
* **Runtime**: `Python 3.12`
* **Architecture**: Deja **x86_64**
* Da clic en **Create Function**.

### 2 - Inyección del código fuente

* En la página de tu función, baja a la sección **Code source**.
* Haz doble clic en el archivo `lambda_function.py` para abrir el editor.
* Reemplaza todo el contenido con el siguiente código de Python. Este código procesa parámetros de la URL y devuelve una página HTML renderizada dinámicamente.

```python
import random

def lambda_handler(event, context):
    nombre = "Estudiante UACH"
    color = "#232F3E"
    is_lucky = False
    
    params = event.get('queryStringParameters') or {}
    
    nombre = params.get('nombre', nombre)
    input_color = params.get('color', color)
    
    if params.get('lucky') in ['1', 'true', 'True']:
        is_lucky = True
        color = "#FFD700"
    elif input_color.lower() == 'random':
        color = f"#{random.randint(0, 0xFFFFFF):06x}"
    else:
        color = input_color

    text_color = "#000000" if is_lucky else "#FFFFFF"
    
    lucky_banner = """
    <div style="background-color: #000000; color: #FFD700; padding: 15px; border-radius: 8px; margin: 20px auto; max-width: 450px; border: 2px solid #FFD700;">
        <h2 style="margin: 0; font-size: 1.5rem;">¡EASTER EGG DESBLOQUEADO!</h2>
        <p style="margin: 8px 0 0 0; color: #FFFFFF;">Muestra esta pantalla a alguien de staff para reclamar tu sticker.</p>
    </div>
    """ if is_lucky else ""

    html_content = f"""
    <html>
        <body style="background-color: {color}; color: {text_color}; font-family: sans-serif; text-align: center; padding-top: 10%;">
            <h1>Serverless UACH</h1>
            <h2>{nombre}</h2>
            <h1 style="font-size: 4rem; text-transform: uppercase;">{color}</h1>
            {lucky_banner}
            <p>Página generada dinámicamente por AWS Lambda.</p>
        </body>
    </html>
    """

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/html',
            'Cache-Control': 'no-store'
        },
        'body': html_content
    }

```

* Da clic en el botón **Deploy** (en la izquierda del editor de código) para guardar y compilar los cambios.

### 3 - Exposición a Internet mediante API Gateway

Las funciones Lambda son privadas por defecto. Para que una aplicación web pueda comunicarse con ella, necesitamos un punto de entrada público.

* En la parte superior de la página (sección **Function overview**), da clic en **+ Add trigger**.
* En el menú desplegable, busca y selecciona **API Gateway**.
* Selecciona **Create a new API**.
* **API type**: Selecciona **HTTP API**.
* **Security**: Selecciona **Open** (Esto permite que cualquiera con el enlace pueda hacer la petición, útil para pruebas).
* Da clic en **Add**.

### 4 - Ejecución y prueba en el mundo real

* Serás redirigido a la vista general de la función. En la pestaña de **Configuration**, selecciona **Triggers**.
* Verás tu API Gateway listado con un **API endpoint** (una URL que empieza con `https://`).
* Copia esa URL, pégala en una nueva pestaña de tu navegador y agrega los parámetros `?nombre=TuNombre&color=random` al final de la URL (ejemplo: `[https://...amazonaws.com/default/sbg-uach-api?nombre=Ricardo&color=random](https://...amazonaws.com/default/sbg-uach-api?nombre=Ricardo&color=random)`).
* Presiona F5 (Refrescar) varias veces. Verás cómo el color de fondo y el código hexadecimal en la página HTML cambian instantáneamente. Cada vez que refrescas, AWS aprovisiona el entorno, ejecuta el código Python y devuelve la interfaz en milisegundos.

### 5 - Auditoría de ejecución en CloudWatch

* Regresa a la consola de tu función Lambda.
* Ve a la pestaña **Monitor** y luego da clic en **View CloudWatch logs**.
* Entra al "Log stream" más reciente.
* Podrás ver el registro exacto de cuántos milisegundos tomó la ejecución de tu código y la memoria que consumió. En la industria, por esto es por lo que pagas: milisegundos de uso, no horas de servidor.

### 6 - Limpieza de recursos (Prevención de cobros huérfanos)

En arquitecturas de nube, los servicios están desacoplados. Eliminar el cómputo (Lambda) no elimina automáticamente el almacenamiento (CloudWatch) ni las reglas de red (API Gateway). Debes purgar cada capa manualmente.

**A. Eliminar la función Lambda (Cómputo):**

* En la consola de Lambda, selecciona tu función `sbg-uach-api`.
* En la parte superior derecha, da clic en **Actions** > **Delete**.
* Confirma la eliminación escribiendo "confirm" si se te solicita.

**B. Eliminar el endpoint en API Gateway (Red):**

* Navega al servicio **API Gateway**.
* Selecciona el API asociado a tu función (usualmente listado con el mismo nombre).
* En la parte superior derecha, da clic en **Delete**.
* Confirma la eliminación.

**C. Limpiar los logs en CloudWatch (Almacenamiento):**

* Navega al servicio **CloudWatch**.
* En el panel izquierdo, bajo **Logs**, da clic en **Log groups**.
* Busca el grupo de logs de tu función (generalmente `/aws/lambda/sbg-uach-api`).
* Selecciónalo marcando la casilla de la izquierda.
* Da clic en **Actions** en la parte superior derecha y selecciona **Delete log group(s)**.
* Confirma la eliminación para evitar cargos permanentes por retención de datos inactivos.
