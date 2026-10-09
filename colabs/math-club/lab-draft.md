# Computación Matemática en AWS: Simulando el Caos con EC2

En este laboratorio vamos a resolver e integrar un sistema de ecuaciones diferenciales no lineales (El Atractor de Lorenz) de forma numérica. Utilizaremos el cómputo de la nube para procesar la integración de miles de puntos y serviremos el resultado visual directamente a una página web.

## Requisitos previos

* Cuenta de AWS activa
* Navegador web moderno

## Prerrequisito adicional

Asegúrate de fijar tu consola de AWS en la región **N. Virginia (us-east-1)**.

## Pasos

### 1 - Provisionamiento de la instancia de cómputo (EC2)

**Desde la consola de AWS (UI)**

* Navega al servicio **EC2**.
* Da clic en **Launch instance** (Lanzar instancia).
* **Name**: `sbg-math-compute`
* **AMI**: Selecciona **Amazon Linux 2023 AMI** (arquitectura **64-bit (x86)**)
* **Instance type**: `t2.micro` / `t3.micro` (*Free tier eligible*)
* **Key pair (login)**: Selecciona **Proceed without a key pair** (Usaremos la terminal en el navegador).

### 2 - Configuración de Redes

**En la sección Network settings**

* Da clic en **Edit**.
* Selecciona **Create security group**.
* **Security group name**: `sbg-math-sg`
* **Inbound security group rules**:
* Regla 1: Type `SSH`, Port `22`, Source `Anywhere` (`0.0.0.0/0`)
* Regla 2: Da clic en **Add security group rule**. Type `HTTP`, Port `80`, Source `Anywhere` (`0.0.0.0/0`)



Da clic en **Launch instance** y espera a que el estado cambie a *Running*.

### 3 - Conexión a la terminal de cómputo

* Selecciona tu instancia `sbg-math-compute`.
* Da clic en **Connect** en la parte superior.
* En la pestaña **EC2 Instance Connect**, da clic en **Connect**. Se abrirá una terminal Linux.

### 4 - Preparar el entorno matemático (Python + SciPy) y el Servidor Web

Ejecuta el siguiente bloque de comandos en la terminal para instalar Apache (para alojar la web) y las librerías matemáticas de Python necesarias para la integración numérica:

```bash
sudo yum update -y
sudo yum install -y httpd python3-pip
sudo pip3 install numpy scipy matplotlib
sudo systemctl start httpd
sudo systemctl enable httpd

```

### 5 - Descargar y ejecutar la simulación

Navega a la carpeta pública del servidor web, descarga el script de cálculo y ejecútalo:

```bash
cd /var/www/html
sudo wget https://raw.githubusercontent.com/RRMforLLM/aws-sbg/refs/heads/beta/labs/math/chaos.py
sudo python3 chaos.py

```

*(Verás mensajes en la terminal confirmando el cálculo y la generación de la gráfica).*

### 6 - Visualización del resultado

* Regresa a la consola de EC2, selecciona tu instancia y copia el valor de **Public IPv4 address**.
* Pégalo en una nueva pestaña de tu navegador (ejemplo: `[http://3.85.12.34](http://3.85.12.34)`).
* Verás la simulación matemática renderizada y lista para ser compartida con el mundo.

### 7 - Iteración y Experimentación (Reto Matemático)

El caos depende altamente de las condiciones iniciales y sus parámetros. Vamos a alterar el comportamiento del atractor modificando la constante $\rho$ (rho).

En tu terminal de EC2, abre el archivo con el editor de texto Nano:

```bash
sudo nano chaos.py

```

* Usa las flechas de tu teclado para buscar la línea que dice `rho = 28.0`.
* Cámbiala por `rho = 14.0` (o `99.0`).
* Guarda el archivo presionando `Ctrl + O`, luego `Enter`, y sal con `Ctrl + X`.

Vuelve a calcular la simulación:

```bash
sudo python3 chaos.py

```

Refresca (F5) la pestaña de tu navegador para ver cómo colapsa la dinámica del sistema basándose en el nuevo parámetro.

### 8 - Limpieza de recursos

Para detener los cargos en tu cuenta:

* En la consola de EC2, selecciona `sbg-math-compute`.
* Da clic en **Instance state** > **Terminate (delete) instance**.
* Confirma y espera a que el estado cambie a *Terminated*.
