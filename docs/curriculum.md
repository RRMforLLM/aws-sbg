# Currículo de AWS SBG

El AWS Student Builder Group de la UACH sigue una ruta práctica y progresiva a
través de los servicios principales de AWS y las arquitecturas modernas de la nube.

Este currículo define la estructura estable de aprendizaje. Las fechas de las
sesiones y su estado pertenecen a [`docs/roadmap.md`](roadmap.md).

## Objetivos de aprendizaje

Al finalizar el programa, el estudiantado podrá:

- Explicar los fundamentos de la computación en la nube y AWS.
- Aplicar conceptos de identidad y privilegio mínimo.
- Desplegar aplicaciones en servidores virtuales.
- Crear aplicaciones serverless orientadas a eventos.
- Diseñar APIs sencillas con almacenamiento persistente.
- Explorar servicios de inteligencia artificial generativa y computación cuántica.
- Identificar costos, riesgos de seguridad y requisitos de limpieza en proyectos de AWS.

## Secuencia del currículo

### 1. IAM y S3

**Servicios de AWS:** IAM, S3, CloudTrail

El estudiantado aprenderá a:

- Crear y administrar identidades de IAM.
- Aplicar políticas de acceso con privilegio mínimo.
- Almacenar y administrar objetos en S3.
- Comprender los nombres de los buckets, los permisos y el acceso público.
- Revisar la actividad mediante CloudTrail.
- Eliminar credenciales y recursos después de experimentar.

**Módulo del currículo:** [`curriculum/01-iam-s3/`](../curriculum/01-iam-s3/)

### 2. EC2 y hosting

**Servicios de AWS:** EC2, EBS y grupos de seguridad

El estudiantado aprenderá a:

- Iniciar y configurar una instancia de EC2.
- Instalar y ejecutar un servidor web.
- Configurar el acceso básico a la red.
- Desplegar una aplicación web sencilla.
- Comprender los costos de cómputo, almacenamiento y red.
- Terminar instancias y eliminar recursos que ya no se utilicen.

**Módulo del currículo:** [`curriculum/02-ec2-hosting/`](../curriculum/02-ec2-hosting/)

### 3. Lambda y computación serverless

**Servicios de AWS:** Lambda y CloudWatch

El estudiantado aprenderá a:

- Crear y desplegar una función de Lambda.
- Procesar datos de una solicitud y devolver una respuesta.
- Comprender la ejecución orientada a eventos.
- Comparar arquitecturas basadas en servidores y serverless.
- Inspeccionar los registros de ejecución y el rendimiento.
- Limpiar las funciones y los recursos relacionados.

**Módulo del currículo:** [`curriculum/03-lambda/`](../curriculum/03-lambda/)

### 4. API Gateway y DynamoDB

**Servicios de AWS:** API Gateway, DynamoDB y Lambda

El estudiantado aprenderá a:

- Exponer funciones de Lambda mediante APIs HTTP.
- Procesar parámetros y respuestas de una API.
- Almacenar y recuperar datos con DynamoDB.
- Conectar varios servicios administrados de AWS.
- Considerar la autenticación, la validación y la limitación de solicitudes.
- Eliminar APIs, tablas, funciones y registros después de utilizarlos.

**Módulo del currículo:** [`curriculum/04-api-gateway-dynamodb/`](../curriculum/04-api-gateway-dynamodb/)

### 5. Amazon Bedrock

**Servicios de AWS:** Amazon Bedrock

El estudiantado aprenderá a:

- Comprender los modelos fundacionales y la inteligencia artificial generativa.
- Enviar prompts a un modelo administrado.
- Diseñar una aplicación sencilla impulsada por inteligencia artificial.
- Considerar el acceso al modelo, el costo, la privacidad y el uso responsable.
- Evaluar los resultados generados y sus limitaciones.

**Módulo del currículo:** [`curriculum/05-bedrock/`](../curriculum/05-bedrock/)

### 6. Amazon Braket

**Servicios de AWS:** Amazon Braket

El estudiantado aprenderá a:

- Comprender los conceptos básicos de la computación cuántica.
- Crear y ejecutar un circuito cuántico sencillo.
- Comparar simuladores con hardware cuántico.
- Interpretar resultados básicos de medición.
- Considerar los límites prácticos y el costo de las cargas de trabajo cuánticas.

**Módulo del currículo:** [`curriculum/06-braket/`](../curriculum/06-braket/)

## Progresión del aprendizaje

Los módulos avanzan desde los conceptos fundamentales de la nube hasta
arquitecturas cada vez más integradas:

```text
IAM y S3
   ↓
EC2 y hosting
   ↓
Lambda
   ↓
API Gateway y DynamoDB
   ↓
Bedrock y Braket

Los primeros cuatro módulos forman la ruta principal de desarrollo de aplicaciones
en AWS. Bedrock y Braket son módulos exploratorios que amplían el programa hacia la
inteligencia artificial generativa y la computación cuántica.

## Contenido de los módulos

Cada módulo del currículo debe contener, cuando corresponda:

- `README.md`: descripción general, objetivos y resultados esperados.
- `prerequisites.md`: cuentas, software y conocimientos previos requeridos.
- `resources.md`: referencias y material de apoyo.
- `presentation.pdf`: presentación utilizada durante la sesión.
- Código de ejemplo o recursos necesarios para el laboratorio.

## Trabajo relacionado

El currículo contiene la ruta de aprendizaje base del AWS SBG.

Los experimentos independientes, clubes y proyectos aplicados pertenecen a
[`colabs/`](../colabs/). Pueden reutilizar conceptos de uno o más módulos del
currículo sin formar parte de la secuencia principal.
