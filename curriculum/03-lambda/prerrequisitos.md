# Guía de Preparación: Prerrequisitos para Laboratorio Lambda y API Gateway

Esta guía cubre exclusivamente la preparación del entorno y el cumplimiento de los prerrequisitos necesarios antes de iniciar el laboratorio.

---

## 1. Acceso a la Consola de AWS

Inicia sesión en la consola desde tu navegador:

```text
https://console.aws.amazon.com

```

* Si usas tu cuenta personal, entra como **Root user** con tu correo.
* Si tienes un usuario IAM, entra como **IAM user** con tu Account ID, usuario y contraseña. El usuario debe tener permisos para crear funciones Lambda, configurar API Gateway y leer logs en CloudWatch.

---

## 2. Selección de Región

En la esquina superior derecha de la consola, junto a tu nombre, asegúrate de seleccionar:

```text
United States (N. Virginia) us-east-1

```

---

## 3. Verificación de Acceso a Lambda

Entra al servicio **Lambda** desde la barra de búsqueda de la consola o directamente con:

```text
https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1

```

**Resultado esperado:** El dashboard de Lambda carga correctamente sin mensajes de *You are not authorized* / *No tienes autorización*.

---

## 4. Verificación de Acceso a API Gateway

Busca el servicio **API Gateway** en la consola o entra directamente con:

```text
https://us-east-1.console.aws.amazon.com/apigateway/main/apis?region=us-east-1

```

**Resultado esperado:** El dashboard de APIs carga correctamente y te permite visualizar el botón para crear una nueva API, sin errores de permisos.

---

## 5. Lista de Control de Prerrequisitos

Marca cada casilla antes de iniciar el **Paso 1** del laboratorio:

* [ ] Inicias sesión en la consola de AWS correctamente.
* [ ] La región seleccionada es explícitamente `us-east-1` (N. Virginia).
* [ ] El dashboard de AWS Lambda carga sin errores de autorización.
* [ ] El dashboard de API Gateway carga sin errores de autorización.
