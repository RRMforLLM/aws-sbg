### Fundamentos de Seguridad en IAM y S3

**Objetivo:** Implementar un entorno de almacenamiento de objetos privado y seguro, donde el acceso esté estrictamente controlado mediante políticas basadas en identidad.

---

#### 1. Introducción: Mentalidad "Security-First" (10 minutos)

* **Contexto:** Explicar por qué IAM es el punto de partida obligatorio para todo desarrollo en la nube.
* **Concepto:** Introducir el "Principio de Privilegio Mínimo" (PoLP): otorgar solo los permisos necesarios para realizar una tarea.
* **Herramientas:** Introducir brevemente la AWS CLI como la herramienta preferida para la gestión profesional de infraestructura.

#### 2. Laboratorio Parte I: Aprovisionamiento de S3 (15 minutos)

* **Acción:** Los estudiantes crean un bucket de S3 con "Block Public Access" (Bloqueo de acceso público) habilitado por defecto.
* **Requisito:** Los nombres de los buckets deben seguir la unicidad global (ej. `sbg-lab-2026-tunombre`).

#### 3. Laboratorio Parte II: IAM y Políticas (30 minutos)

* **Tarea:** Los estudiantes crean un usuario o rol de IAM específicamente para interactuar con el bucket.
* **Creación de Políticas:** Los estudiantes redactan una política de IAM en JSON.
* *Lógica del ejemplo:* Permitir `s3:GetObject` y `s3:PutObject` solo en el ARN específico del bucket.


* **Bloque Condition:** Los estudiantes añaden una condición (`Condition`) a la política que limita el acceso a un rango de IP específico o a un punto de enlace de VPC para demostrar restricciones avanzadas.

#### 4. Laboratorio Parte III: Verificación y Auditoría (15 minutos)

* **Validación:** Los estudiantes prueban el acceso intentando subir un archivo desde una máquina no autorizada o con una identidad sin permisos.
* **Auditoría:** Utilizar **AWS CloudTrail** para localizar los registros de eventos de `AccessDenied`, confirmando que la política de seguridad está funcionando según lo previsto.

---

### Requisitos Técnicos para los Estudiantes

* **Prerrequisitos:** Cuenta de AWS con la CLI configurada.
* **Herramientas:** Uso obligatorio de `JSON` para todas las definiciones de políticas de IAM.
* **Gobierno:** Los estudiantes deben usar **AWS Cost Explorer** al finalizar la sesión para asegurar que no han generado costos inesperados.
