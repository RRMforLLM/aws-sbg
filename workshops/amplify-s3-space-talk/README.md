# Ingestión Masiva de Datos NASA: Next.js, AWS Amplify y Amazon S3

## Contexto de la Industria

Un dataset satelital no cabe en una función serverless: en Vercel, el cuerpo de una petición tiene un límite fijo de [4.5 MB](https://vercel.com/kb/guide/vercel-file-uploads) y cualquier archivo mayor devuelve un error `413`. La solución es que el archivo nunca pase por la función.

En este laboratorio cada equipo despliega una aplicación web que envía los archivos directo a Amazon S3 mediante **URLs prefirmadas**:

1. El frontend pide permiso a la API con una petición `GET`. Solo viajan el nombre y el tipo del archivo.
2. La API Route usa el AWS SDK para generar una URL temporal, firmada con las credenciales del servidor.
3. El frontend sube el archivo con un `PUT` directo a esa URL, sin pasar por el servidor.

Después, la misma aplicación consulta esos archivos: la API los lista y genera una URL temporal de lectura, y el navegador los descarga directo de S3. Amplify y S3 son servicios separados: la aplicación solo puede hacer con el bucket lo que permiten sus credenciales.

**Vercel y Amplify:** Vercel es excelente para desplegar interfaces ligeras. Aquí usamos AWS Amplify y S3 porque el almacenamiento, los permisos y el hosting quedan en una sola cuenta de AWS, lo que da una base real para ingerir datos a escala de gigabytes. El patrón de URLs prefirmadas es lo que elimina el límite; también funcionaría desde Vercel apuntando a S3.

## Requisitos previos

- Cuenta de AWS activa.
- Cuenta de GitHub.
- Navegador web moderno. Todo el laboratorio se hace desde la consola: no necesitas AWS CLI ni instalar Node.js.
- Repositorio base del laboratorio:

[https://github.com/RRMforLLM/nasa-s3-ingest](https://github.com/RRMforLLM/nasa-s3-ingest)

* Un archivo de prueba científico. Descarga con anticipación el dataset NetCDF de temperaturas (aprox. 45 MB) directamente de la NOAA:
`https://downloads.psl.noaa.gov/Datasets/NARR/Dailies/monolevel/air.2m.2023.nc`

## Prerrequisito adicional

Fija tu consola de AWS en la región `us-east-1` (N. Virginia).

Los nombres de bucket son únicos a nivel global. Define un identificador para tu equipo (ej. `equipo07`) y úsalo donde aparezca `<equipo>`. A partir de aquí, tu bucket se llamará `sbg-uach-nasa-<equipo>`.

## Pasos

### 1 - Creación del bucket S3

* Navega al servicio **S3** y da clic en **Create bucket**.
* **Bucket type**: **General purpose** (si aparece la opción).
* **Bucket name**: `sbg-uach-nasa-<equipo>`
* **Block Public Access**: Deja activado **Block all public access**. Las URLs prefirmadas funcionan con el bucket privado.
* Da clic en **Create bucket**.

### 2 - Usuario IAM con privilegio mínimo

La API necesita credenciales para firmar las URLs. Una URL prefirmada solo puede hacer lo que su firmante tiene permitido, así que este usuario únicamente podrá escribir en `uploads/`.

**Crear el usuario**

* Navega a **IAM** > **Users** > **Create user**.
* **User name**: `sbg-nasa-api-<equipo>`
* No actives el acceso a la consola.
* En **Set permissions**, avanza sin seleccionar nada y da clic en **Create user**.

**Agregar la política inline**

* Entra a tu usuario. En la pestaña **Permissions**, da clic en **Add permissions** > **Create inline policy**.
* Selecciona la vista **JSON** y pega lo siguiente, reemplazando `<equipo>`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PermitirSoloSubidas",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::sbg-uach-nasa-<equipo>/uploads/*"
    }
  ]
}

```

* **Policy name**: `sbg-nasa-putobject`
* Da clic en **Create policy**.

**Crear las claves de acceso**

* En la pestaña **Security credentials**, baja a **Access keys** y da clic en **Create access key**.
* **Use case**: Selecciona **Other** y da clic en **Next**, luego en **Create access key**.
* Copia el **Access key** y el **Secret access key**. El secreto solo se muestra esta vez.

### 3 - Copia del repositorio

* Abre el repositorio base y da clic en **Fork** para crear una copia en tu cuenta de GitHub.
* Revisa estos archivos antes de continuar:
* `app/page.tsx`: pide la URL a la API con `GET` y sube el archivo con `PUT`.
* `app/api/upload/route.ts`: crea el `S3Client` y genera la URL con `PutObjectCommand` y `getSignedUrl`.
* `app/api/files/route.ts`: lista los archivos de `uploads/` con `ListObjectsV2Command`.
* `app/api/files/open/route.ts`: genera una URL de lectura con `GetObjectCommand` y redirige al navegador.
* `amplify.yml`: copia las variables de entorno a `.env.production` durante la compilación. Sin este paso, Next.js [no puede leerlas en el servidor](https://docs.aws.amazon.com/amplify/latest/userguide/ssr-environment-variables.html).



### 4 - Despliegue en AWS Amplify

* Navega al servicio **AWS Amplify** y da clic en **Create new app**.
* Selecciona **GitHub** como proveedor y autoriza el acceso cuando se te solicite.
* Elige tu copia del repositorio y la rama `main`. Da clic en **Next**.
* Verifica que Amplify detecte **Next.js** y el archivo `amplify.yml`.
* En **Service role**, permite que Amplify cree un rol nuevo.
* Abre **Advanced settings** y agrega estas cuatro variables **antes de compilar**:

| Variable | Valor |
| --- | --- |
| `S3_BUCKET_NAME` | `sbg-uach-nasa-<equipo>` |
| `S3_REGION` | `us-east-1` |
| `S3_ACCESS_KEY_ID` | El Access key del paso 2 |
| `S3_SECRET_ACCESS_KEY` | El Secret access key del paso 2 |

Los nombres empiezan con `S3_` porque Amplify [no permite crear variables con el prefijo `AWS](https://docs.aws.amazon.com/amplify/latest/userguide/environment-variables.html)`.

* Da clic en **Next** y luego en **Save and deploy**.
* Espera a que la compilación termine. Copia el dominio de tu aplicación, que tiene la forma `https://main.<APP_ID>.amplifyapp.com`.

### 5 - Primera subida (bloqueo esperado)

* Abre tu aplicación y presiona **F12** para ver la pestaña **Console**. El panel **Archivos en S3** muestra `AccessDenied`: es esperado y lo resolvemos en el paso 8.
* Selecciona tu archivo NetCDF de la NOAA y da clic en **Subir a S3**.
* Verifica que la subida falle con un error de CORS en la consola.

La API sí generó la URL. El bloqueo ocurre porque el navegador pregunta a S3 si tu dominio puede hacer un `PUT`, y S3 todavía no lo autoriza.

### 6 - Configuración de CORS en S3

* En la consola de S3, entra a tu bucket y abre la pestaña **Permissions**.
* Baja a **Cross-origin resource sharing (CORS)** y da clic en **Edit**.
* Pega lo siguiente, reemplazando `<APP_ID>` con el de tu dominio:

```json
[
  {
    "AllowedHeaders": ["Content-Type"],
    "AllowedMethods": ["PUT"],
    "AllowedOrigins": [
      "https://main.<APP_ID>.amplifyapp.com",
      "http://localhost:3000"
    ],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]

```

* Da clic en **Save changes**.

El origen debe coincidir exactamente: con `https://` y sin `/` al final.

### 7 - Ingestión y comprobación

* Regresa a tu aplicación, abre la pestaña **Network** de las herramientas de desarrollador y recarga la página.
* Sube tu archivo de nuevo. La barra debe avanzar hasta el 100% y mostrar el tiempo y la velocidad.
* En **Network**, identifica la petición a `/api/upload` y el `PUT` al dominio `s3.us-east-1.amazonaws.com`. El archivo completo viaja en el `PUT`, no en la petición a tu API.
* En la consola de S3, abre `uploads/` en tu bucket y confirma que el tamaño del objeto coincide con tu archivo.

### 8 - Ampliación de permisos para consultar los datos

Tu archivo ya está en S3, pero la aplicación no puede verlo: el panel **Archivos en S3** sigue mostrando `AccessDenied`. Su usuario IAM solo tiene permiso para escribir.

* En **IAM** > **Users**, entra a `sbg-nasa-api-<equipo>`.
* En la pestaña **Permissions**, abre la política `sbg-nasa-putobject` y da clic en **Edit**.
* En la vista **JSON**, reemplaza todo con lo siguiente, sustituyendo `<equipo>`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PermitirSubirYLeer",
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::sbg-uach-nasa-<equipo>/uploads/*"
    },
    {
      "Sid": "PermitirListarUploads",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::sbg-uach-nasa-<equipo>",
      "Condition": {
        "StringLike": { "s3:prefix": "uploads/*" }
      }
    }
  ]
}

```

* Da clic en **Next** y luego en **Save changes**.

`s3:ListBucket` aplica sobre el bucket, por eso su `Resource` no lleva `/*`. Las acciones sobre archivos sí lo llevan. No necesitas volver a desplegar, porque los permisos se evalúan en cada petición.

### 9 - Consulta de los archivos

* Regresa a tu aplicación, deja abierta la pestaña **Network** y da clic en **Actualizar** en el panel **Archivos en S3**. Tu archivo debe aparecer con su tamaño y fecha. Si sigue el error, espera unos segundos y vuelve a intentar.
* Da clic en **Descargar**. En **Network**, identifica la petición a `/api/files/open` con respuesta `302` y la redirección al dominio de S3. El archivo NetCDF comenzará a descargarse a tu equipo.

El listado pasa por el servidor, así que el navegador no habla con S3. Descargar es una navegación normal, no una petición de JavaScript, así que CORS no aplica y tampoco cambia. En ambos casos, el archivo nunca pasa por Amplify.

### 10 - Conexión con Data Science (Python y Boto3)

En un entorno real de hackathon, el equipo es distribuido. Un integrante ingiere los datos desde la interfaz web, y otro los extrae desde la nube a su entorno de desarrollo local.

Para demostrar esta conexión, abre Google Colab o un Jupyter Notebook local y ejecuta el siguiente script para descargar y leer el dataset directamente en tu entorno de procesamiento.

**Instalación de dependencias:**

```bash
pip install boto3 xarray netCDF4

```

**Script de extracción:**

```python
import boto3
import xarray as xr

# Credenciales IAM generadas en el Paso 2
s3 = boto3.client(
    's3',
    region_name='us-east-1',
    aws_access_key_id='TU_ACCESS_KEY',
    aws_secret_access_key='TU_SECRET_KEY'
)

bucket_name = 'sbg-uach-nasa-<equipo>'
file_key = 'uploads/air.2m.2023.nc'
local_file = 'air.2m.2023.nc'

print("Descargando dataset de 300MB desde S3...")
# Descarga a disco local en lugar de RAM para evitar cuelgues en entornos limitados
s3.download_file(bucket_name, file_key, local_file)

print("Procesando NetCDF...")
# Abrir el dataset científico
ds = xr.open_dataset(local_file)

# Imprimir los metadatos y dimensiones para comprobar lectura exitosa
print(ds)

```

Esto demuestra la arquitectura final: la infraestructura serverless maneja la ingesta pesada, y Python interactúa directamente con el bucket S3 como un *Data Lake* centralizado, sin pasar por el frontend.

### 11 - Registro de tiempos

Anota los tiempos de tu equipo y compártelos con el staff.

| Etapa | Tiempo medido |
| --- | --- |
| Bucket y usuario IAM (pasos 1 y 2) |  |
| Copia del repositorio y primera compilación (pasos 3 y 4) |  |
| Diagnóstico y corrección de CORS (pasos 5 y 6) |  |
| Subida del archivo (paso 7) |  |
| Velocidad de subida en MB/s (paso 7) |  |
| Ampliación de permisos y consulta (pasos 8 y 9) |  |
| Conexión con Python (paso 10) |  |

### 12 - Auditoría con CloudTrail

* Navega a **CloudTrail** > **Event history**.
* Filtra por **Resource name** con el nombre de tu bucket.
* Confirma los eventos `CreateBucket` y `PutBucketCors`. Pueden tardar unos minutos en aparecer.

Las subidas (`PutObject`) no aparecen aquí: son eventos de datos, y CloudTrail no los registra por defecto.

### 13 - Limpieza de recursos

**A. Eliminar la aplicación de Amplify (Hosting):**

* En Amplify, entra a tu aplicación > **App settings** > **General settings**.
* Da clic en **Delete app** y confirma.

**B. Vaciar y eliminar el bucket (Almacenamiento):**

* En S3, selecciona tu bucket y da clic en **Empty**. Confirma escribiendo `permanently delete`.
* Selecciona de nuevo el bucket, da clic en **Delete** y confirma escribiendo su nombre.

**C. Eliminar el usuario IAM (Credenciales):**

* En **IAM** > **Users**, selecciona `sbg-nasa-api-<equipo>` y da clic en **Delete**. Esto también elimina sus claves y su política inline.

**D. Eliminar lo que Amplify creó por ti (Rol y logs):**

* En **IAM** > **Roles**, busca `Amplify` y elimina el rol creado para esta aplicación. Si la cuenta tiene otras aplicaciones de Amplify, verifica primero que no lo usen.
* En **CloudWatch** > **Log groups**, elimina `/aws/amplify/<APP_ID>` si existe.

**E. Revocar el acceso de GitHub (opcional):**

* En GitHub, ve a **Settings** > **Applications** y revoca el acceso de AWS Amplify si ya no lo usarás.

## Solución de bloqueos

Firmar una URL no contacta a AWS, así que unas credenciales incorrectas no fallan en la API: fallan después, en el `PUT` a S3.

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| La compilación falla en el comando `env | grep` | No hay ninguna variable `S3_*` en Amplify | Agrega las cuatro variables y vuelve a desplegar |
| La API responde `Faltan variables de entorno` | Falta una variable, o se agregó después de compilar | Corrige el nombre y vuelve a desplegar: `.env.production` se genera en la compilación |
| Error de CORS en la consola del navegador | El bucket no tiene CORS, o el origen no coincide | Compara el origen con tu dominio exacto (paso 6) |
| `403 AccessDenied` en el `PUT` | La política no cubre ese bucket o la ruta `uploads/*` | Revisa el `Resource` de la política (paso 2) |
| `AccessDenied` en el panel **Archivos en S3** | Falta `s3:ListBucket`, o su `Resource` lleva `/*` | Revisa la política (paso 8) |
| XML con `AccessDenied` al abrir o descargar | Falta `s3:GetObject` sobre `uploads/*` | Revisa la política (paso 8) |
| `403 InvalidAccessKeyId` | Access key incorrecta o eliminada | Corrige `S3_ACCESS_KEY_ID` y vuelve a desplegar |
| `403 SignatureDoesNotMatch` | Secret incorrecto, a menudo con espacios al copiarlo | Corrige `S3_SECRET_ACCESS_KEY` y vuelve a desplegar |
| `403` con el mensaje `Request has expired` | Pasaron más de 15 minutos desde que se generó la URL | Intenta la subida de nuevo para obtener otra URL |
| Redirección o error de CORS solo con ciertos valores de región | `S3_REGION` no es la región del bucket | Usa la región exacta del bucket y vuelve a desplegar |
| La aplicación rechaza un archivo mayor a 5 GB | Es el [máximo de S3 para un solo `PUT](https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html)` | Fuera del alcance de este laboratorio: se requiere carga multiparte |

Cada cambio de variables requiere un nuevo despliegue. Un cambio de CORS se aplica sin desplegar, pero recarga la página: el navegador puede conservar la respuesta anterior hasta `MaxAgeSeconds`.

## Recomendaciones de seguridad

* **Credenciales de larga duración**
* Este laboratorio usa claves de acceso por simplicidad. Amplify [recomienda no guardar secretos en variables de entorno](https://docs.aws.amazon.com/amplify/latest/userguide/environment-variables.html). En producción, usa un rol IAM para el cómputo de la aplicación.


* **Autenticación de la API**
* La ruta `/api/upload` es pública: cualquiera con el enlace puede obtener una URL y escribir en tu bucket. Desde el paso 8, también puede ver y descargar todos los archivos de `uploads/`. No subas datos privados en este laboratorio. En producción, exige una sesión antes de listar o firmar.


* **Tamaño de los archivos**
* Una URL prefirmada para `PUT` no limita el tamaño del archivo, y el almacenamiento genera costos. Controla el tamaño y agrega reglas de ciclo de vida al bucket.


* **Principio de Privilegio Mínimo (PoLP)**
* Limita cada credencial a la acción y la ruta que necesita, como `s3:PutObject` y `s3:GetObject` sobre `uploads/*`. Agrega un permiso solo cuando la aplicación lo necesite.


* **Vigencia de las URLs**
* Una URL prefirmada funciona para quien la tenga hasta que expira. Mantén vigencias cortas y no la guardes en logs.


* **Bloqueo del acceso público**
* Mantén activo **Block all public access**. Un error de CORS se corrige con CORS, nunca abriendo el bucket.
