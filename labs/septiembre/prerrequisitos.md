# Guía de Preparación: Prerrequisitos para Laboratorio EC2 y Apache

Esta guía cubre exclusivamente la preparación del entorno y el cumplimiento de los prerrequisitos necesarios antes de iniciar el laboratorio.

---

## 1. Acceso a la Consola de AWS

Inicia sesión en la consola desde tu navegador:

```
https://console.aws.amazon.com
```

* Si usas tu cuenta personal, entra como **Root user** con tu correo.
* Si tienes un usuario IAM, entra como **IAM user** con tu Account ID, usuario y contraseña. El usuario debe tener permisos para crear instancias EC2 y security groups.

> **Nota:** Si al entrar aparece un aviso para completar el registro o verificar tu método de pago, termínalo antes del laboratorio; de lo contrario no podrás lanzar instancias.

---

## 2. Selección de Región

En la esquina superior derecha de la consola, junto a tu nombre, selecciona:

```text
United States (N. Virginia) us-east-1
```

---

## 3. Verificación de Acceso a EC2

Entra al servicio **EC2** desde la barra de búsqueda de la consola o directamente con:

```
https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1
```

**Resultado esperado:** El dashboard de EC2 carga sin mensajes de *You are not authorized* / *No tienes autorización*.

---

## 4. Verificación del Código de la Aplicación

Abre la URL cruda del archivo en una pestaña de tu navegador:

```
https://raw.githubusercontent.com/RRMforLLM/aws-sbg/refs/heads/beta/labs/septiembre/roulette.html
```

**Resultado esperado:** Se muestra el código HTML en texto plano. Si aparece `404: Not Found`, avisa al instructor antes de iniciar.

---

## 5. Lista de Control de Prerrequisitos

Marca cada casilla antes de iniciar el **Paso 1** del laboratorio:

* [ ] Inicias sesión en la consola de AWS sin avisos pendientes de registro.
* [ ] La región seleccionada es `us-east-1` (N. Virginia).
* [ ] El dashboard de EC2 carga sin errores de autorización.
* [ ] La URL cruda de `roulette.html` muestra el código HTML.
