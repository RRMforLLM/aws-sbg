# AWS Student Builder Group — UACH

Repositorio de aprendizaje práctico del **AWS Student Builder Group de la
UACH**. Contiene el currículo de AWS, laboratorios guiados, experimentos
interdisciplinarios, workshops y material de sesiones.

La ruta principal avanza desde identidad y almacenamiento hasta arquitecturas
serverless, APIs, inteligencia artificial generativa y computación cuántica.
La documentación y los materiales están principalmente en español.

## Mapa del repositorio

```text
aws-sbg/
├── README.md                         # Índice general del repositorio
├── docs/
│   ├── curriculum.md                 # Objetivos y secuencia de aprendizaje
│   └── roadmap.md                    # Sesiones, fechas y estado
├── curriculum/                       # Módulos guiados de AWS
│   ├── 01-iam-s3/
│   ├── 02-ec2-hosting/
│   ├── 03-lambda/
│   ├── 04-api-gateway-dynamodb/
│   ├── 05-bedrock/
│   └── 06-braket/
├── colabs/                           # Colaboraciones, clubes y proyectos
│   ├── math-club/
│   └── videogame-club/
├── workshops/                        # Talleres temáticos
│   └── amplify-s3-space-talk/
└── meetups/                          # Material de encuentros
    └── 2026-10/
```

## Ruta principal de aprendizaje

La definición completa de objetivos, servicios y progresión está en
[`docs/curriculum.md`](docs/curriculum.md). Los módulos disponibles son:

| Módulo | Servicios o tema | Material |
| --- | --- | --- |
| **01 — IAM y S3** | Identidad, privilegio mínimo, buckets, políticas y CloudTrail | [`README.md`](curriculum/01-iam-s3/README.md), [`prerrequisitos.md`](curriculum/01-iam-s3/prerrequisitos.md), [`recursos.md`](curriculum/01-iam-s3/recursos.md), [`presentacion.pdf`](curriculum/01-iam-s3/presentacion.pdf) |
| **02 — EC2 y hosting** | Instancias, redes, Apache y despliegue de una ruleta web | [`README.md`](curriculum/02-ec2-hosting/README.md), [`prerrequisitos.md`](curriculum/02-ec2-hosting/prerrequisitos.md), [`recursos.md`](curriculum/02-ec2-hosting/recursos.md), [`roulette.html`](curriculum/02-ec2-hosting/roulette.html), [`presentacion.pdf`](curriculum/02-ec2-hosting/presentacion.pdf) |
| **03 — Lambda** | Funciones serverless, API Gateway, CloudWatch y limpieza de recursos | [`README.md`](curriculum/03-lambda/README.md), [`prerrequisitos.md`](curriculum/03-lambda/prerrequisitos.md), [`recursos.md`](curriculum/03-lambda/recursos.md) |
| **04 — API Gateway y DynamoDB** | APIs HTTP, persistencia y conexión de servicios administrados | Carpeta reservada para el material del módulo |
| **05 — Bedrock** | Modelos fundacionales, prompts, evaluación y uso responsable de IA generativa | Carpeta reservada para el material del módulo |
| **06 — Braket** | Circuitos, simuladores y fundamentos de computación cuántica | Carpeta reservada para el material del módulo |

Cada módulo puede incluir una guía principal, prerrequisitos, recursos,
presentación y código o archivos de apoyo. Las fechas y el estado de cada
sesión se mantienen en [`docs/roadmap.md`](docs/roadmap.md).

## Colaboraciones y clubes

### Club de matemáticas

[`colabs/math-club/`](colabs/math-club/) contiene un laboratorio de cómputo
científico en EC2 basado en el atractor de Lorenz:

- [`lab-draft.md`](colabs/math-club/lab-draft.md): guía para aprovisionar EC2,
  instalar Python, NumPy, SciPy y Matplotlib, y servir el resultado.
- [`chaos.py`](colabs/math-club/chaos.py): integra numéricamente el sistema de
  Lorenz y genera la visualización.
- [`index.html`](colabs/math-club/index.html) y [`lorenz.png`](colabs/math-club/lorenz.png):
  salida web y gráfica de referencia.

### Club de videojuegos

[`colabs/videogame-club/`](colabs/videogame-club/) explora Live Ops y
sincronización de estado entre un juego y un backend:

- [`fundamentos-de-live-ops.md`](colabs/videogame-club/fundamentos-de-live-ops.md):
  laboratorio con EC2, Flask y una interfaz para modificar el estado del juego.
- [`Juego/`](colabs/videogame-club/Juego/): proyecto Godot 4.x.
  Incluye configuración del proyecto, recursos gráficos en `Assets/`, escenas
  en `Escenas/` y scripts de gameplay, niveles, NPCs, monedas, plataformas y
  comunicación en `Scripts/`.
- [`juego.zip`](colabs/videogame-club/juego.zip): paquete comprimido del juego.

## Workshops

[`workshops/amplify-s3-space-talk/`](workshops/amplify-s3-space-talk/) contiene
el taller [`README.md`](workshops/amplify-s3-space-talk/README.md) de ingestión
de archivos grandes con **Next.js, AWS Amplify y Amazon S3**. El flujo usa una
API para generar URLs prefirmadas y una subida `PUT` directa a S3, incluyendo
configuración de IAM, CORS, CloudTrail y limpieza.

## Meetups

[`meetups/2026-10/`](meetups/2026-10/) conserva la presentación PDF del meetup
de octubre de 2026.

## Cómo usar este repositorio

1. Revisa [`docs/curriculum.md`](docs/curriculum.md) para entender la ruta.
2. Consulta los prerrequisitos del módulo antes de abrir la consola de AWS.
3. Sigue el `README.md` del módulo o laboratorio elegido.
4. Usa una región consistente y nombres únicos para tus recursos.
5. Elimina instancias, buckets, usuarios, APIs, funciones y grupos de logs al
   terminar para evitar cargos y recursos huérfanos.

Los laboratorios son material educativo: adapta permisos, exposición de red y
credenciales antes de reutilizar cualquier ejemplo en producción. Nunca
guardes claves de AWS en este repositorio.
