# Fundamentos de Hosting y Servidores: Amazon EC2 y Apache

## Requisitos previos

* Cuenta de AWS activa
* Navegador web moderno
* URL cruda (raw) del repositorio de GitHub con el código de la aplicación web (Ruleta)

## Prerrequisito adicional

Antes de comenzar, asegurate de fijar tu consola de AWS en una región específica (ej. `us-east-1` N. Virginia). Todos los recursos deben crearse en la misma región para mantener el orden y evitar costos residuales de recursos huérfanos.

## Pasos

### 1 - Provisionamiento de la instancia EC2

**Desde la consola de AWS (UI)**

* Navega al servicio **EC2**.
* Da clic en **Launch instance** (Lanzar instancia).
* **Name**: `sbg-uach-web-server`
* **AMI**: Selecciona **Amazon Linux 2023 AMI**
* **Instance type**: `t2.micro` (Apto para la capa gratuita)
* **Key pair (login)**: Selecciona **Proceed without a key pair** (No recomendado en producción, pero óptimo para este laboratorio utilizando Instance Connect).

### 2 - Configuración de Redes y Seguridad

**En la sección Network settings**

* Da clic en **Edit**.
* Selecciona **Create security group**.
* **Security group name**: `sbg-web-sg`
* **Inbound security group rules**:
* Regla 1: Type `SSH`, Port `22`, Source `Anywhere` (`0.0.0.0/0`)
* Regla 2: Da clic en **Add security group rule**. Type `HTTP`, Port `80`, Source `Anywhere` (`0.0.0.0/0`)

Da clic en **Launch instance** y espera a que el estado cambie a *Running*.

### 3 - Conexión a la instancia

* Selecciona tu instancia `sbg-uach-web-server`.
* Da clic en **Connect** en la parte superior.
* En la pestaña **EC2 Instance Connect**, deja el usuario por defecto (`ec2-user`) y da clic en **Connect**. Se abrirá una terminal directamente en tu navegador.

### 4 - Instalación del servidor web (Apache)

**Ejecuta los siguientes comandos en la terminal de EC2 Instance Connect:**

```bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
```

**Verifica que el servicio esté corriendo:**

```bash
sudo systemctl status httpd
```

*(Presiona `q` para salir del status).*

### 5 - Despliegue de la aplicación (Ruleta)

**Navega al directorio público del servidor y descarga el código fuente:**

```bash
cd /var/www/html
sudo wget <TU_URL_DE_GITHUB_RAW_INDEX_HTML>
```

*(Reemplaza `<TU_URL_DE_GITHUB_RAW_INDEX_HTML>` por la URL real de tu archivo).*

### 6 - Ejecución de la aplicación

* Regresa a la consola de EC2.
* Selecciona tu instancia y copia el valor de **Public IPv4 address**.
* Pega la IP en una nueva pestaña de tu navegador (asegurate de usar `http://` y no `https://`).
* La aplicación debe cargar inmediatamente. Ejecuta el sorteo.

### 7 - Limpieza de recursos

**Termina la instancia para detener los cargos de cómputo y almacenamiento:**

* En la consola de EC2, selecciona `sbg-uach-web-server`.
* Da clic en **Instance state** > **Terminate instance**.
* Confirma la terminación.
* *(Opcional)* Navega a **Security Groups** en el panel izquierdo y elimina `sbg-web-sg` una vez que la instancia haya sido terminada por completo.

## Recomendaciones de seguridad

* **Exposición de puertos**
* Nunca abras el puerto 22 (SSH) al público (`0.0.0.0/0`) en un entorno de producción. Restringilo a tu IP estática o utiliza AWS Systems Manager (SSM).

* **Gestión de accesos**
* Utiliza Key Pairs y rotalos periódicamente si el acceso SSH directo es estrictamente necesario.

* **Control de costos**
* Termina las instancias que no estés utilizando; simplemente detenerlas detiene el cobro de cómputo, pero los volúmenes de almacenamiento (EBS) asociados seguirán generando costos.
