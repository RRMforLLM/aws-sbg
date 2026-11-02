# Guía de Preparación: Prerrequisitos para Laboratorio IAM y S3

Esta guía cubre exclusivamente la preparación del entorno y el cumplimiento de los prerrequisitos necesarios antes de iniciar el laboratorio.

---

## 1. Instalación de AWS CLI

Instala la herramienta oficial según tu sistema operativo:

### Linux / WSL / macOS
```bash
# Descargar el instalador oficial
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"

# Descomprimir
unzip awscliv2.zip

# Instalar a nivel de sistema
sudo ./aws/install

# Limpiar instalador temporal
rm -rf aws awscliv2.zip
```

> **macOS (Alternativa con Homebrew):**
> ```bash
> brew install awscli
> ```

### Windows (PowerShell)

Ejecuta en una ventana de PowerShell:

```powershell
winget install -e --id Amazon.AWSCLI
```

---

## 2. Verificación de la Instalación

Reinicia tu terminal y ejecuta:

```bash
aws --version
```

**Resultado esperado:** Versión `aws-cli/2.x.x` con su correspondiente entorno de ejecución.

---

## 3. Generación de Credenciales Administrativas (Consola AWS)

Para que la CLI tenga permisos de crear usuarios IAM y buckets S3:

1. Entra a la **Consola de AWS** $\rightarrow$ Servicio **IAM**.
2. Dirígete a **Users (Usuarios)** y haz clic en tu usuario administrador.
3. Ve a la pestaña **Security credentials (Credenciales de seguridad)**.
4. Baja a la sección **Access keys (Claves de acceso)** y selecciona **Create access key**.
5. Marca el caso de uso **Command Line Interface (CLI)**, acepta las recomendaciones y pulsa **Next** $\rightarrow$ **Create access key**.
6. Copia y guarda inmediatamente:
* **Access Key ID**
* **Secret Access Key**

---

## 4. Configuración del Perfil Principal

En tu terminal, ejecuta el configurador interactivo:

```bash
aws configure
```

Ingresa los valores solicitados:

```text
AWS Access Key ID [None]: <Tu-Access-Key-ID>
AWS Secret Access Key [None]: <Tu-Secret-Access-Key>
Default region name [None]: us-east-1
Default output format [None]: json
```

### Validar Identidad y Conexión

```bash
aws sts get-caller-identity
```

Debe retornar un JSON con tu `Account`, `UserId` y el `Arn` de tu usuario/rol administrador.

---

## 5. Crear archivo de texto para pruebas

```bash
echo "Prueba de subida S3 - Laboratorio IAM" > archivo_test.txt
```

---

## 6. Lista de Control de Prerrequisitos

Marca cada casilla antes de iniciar el **Paso 0** del laboratorio:

* [ ] `aws --version` ejecuta sin errores (CLI v2).
* [ ] `aws sts get-caller-identity` autentica correctamente contra tu cuenta de AWS.
* [ ] `archivo_test.txt` está creado en el directorio actual (`ls archivo_test.txt`).
