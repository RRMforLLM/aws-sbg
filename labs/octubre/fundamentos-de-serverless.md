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
* Da clic en **Create Event Function**.
* Selecciona **Author from scratch**.
* **Function name**: `sbg-uach-api`
* **Runtime**: `Python 3.12`
* **Architecture**: Deja **x86_64**
* Da clic en **Create Event Function**.

### 2 - Inyección del código fuente

* En la página de tu función, baja a la sección **Code source**.
* Haz doble clic en el archivo `lambda_function.py` para abrir el editor.
* Reemplaza todo el contenido con el siguiente código de Python. Este código simula un microservicio backend que devuelve datos en formato JSON.

```python
import json
import random

def lambda_handler(event, context):
    respuestas = [
        "Es un problema de DNS.",
        "Funciona en mi maquina local.",
        "Limpiaste la cache del navegador?",
        "Reinicia el router."
    ]
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'diagnostico_it': random.choice(respuestas),
            'tecnologia': 'AWS Lambda Serverless'
        })
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
* Copia esa URL y pégala en una nueva pestaña de tu navegador.
* Presiona F5 (Refrescar) varias veces. Verás cómo la respuesta JSON cambia dinámicamente. Cada vez que refrescas, AWS aprovisiona el entorno, ejecuta el código Python y devuelve el resultado en milisegundos.

### 5 - Auditoría de ejecución en CloudWatch

* Regresa a la consola de tu función Lambda.
* Ve a la pestaña **Monitor** y luego da clic en **View CloudWatch logs**.
* Entra al "Log stream" más reciente.
* Podrás ver el registro exacto de cuántos milisegundos tomó la ejecución de tu código y la memoria que consumió. En la industria, por esto es por lo que pagas: milisegundos de uso, no horas de servidor.

### 6 - Limpieza de recursos

**Eliminar la función para mantener la cuenta limpia:**

* En la consola de Lambda, selecciona tu función `sbg-uach-api`.
* En la parte superior derecha, da clic en **Actions** > **Delete**.
* Confirma la eliminación escribiendo "delete" si se te solicita. Al eliminar la función Lambda, el trigger de API Gateway asociado también se deshabilita.
