# Fundamentos de seguridad en AWS: IAM y S3

## Requisitos previos

- Cuenta de AWS activa
- AWS CLI instalado y configurado
- Un archivo de texto local para pruebas (ej. `archivo_test.txt`)
- Permisos para crear usuarios IAM y buckets S3

## Prerrequisito adicional

Antes de comenzar, cada estudiante debe generar un identificador único para evitar colisiones de nombres (los nombres de bucket S3 son únicos a nivel global, así que si 30 estudiantes usan el mismo nombre literal, solo el primero tendrá éxito).

- Definir una variable de entorno con tu nombre de bucket único:

```bash
export STUDENT_ID=<tu-usuario-o-numero-de-lista> # ej: jperez, alumno07, etc.
export BUCKET_NAME=sbg-uach-test-lab-2026-${STUDENT_ID}
```

- Verificar que quedó bien definida:

```bash
echo $BUCKET_NAME
```

A partir de aquí, todos los comandos usan `$BUCKET_NAME` en vez del nombre fijo.

## Pasos

### 0 - Verificar la configuración actual

```bash
aws sts get-caller-identity
```

### 1 - Crear un bucket con un nombre único a nivel global

```bash
aws s3 mb s3://$BUCKET_NAME --region us-east-1
```

### 2 - Crear un usuario y credenciales

**Crear el usuario**

```bash
aws iam create-user --user-name sbg-student-test
```

**Crear las claves de acceso** (guardar el JSON resultante)

```bash
aws iam create-access-key --user-name sbg-student-test
```

**Guardar el `AccessKeyId` y `SecretAccessKey`** del JSON resultante y configurarlos como un perfil nuevo:

```bash
aws configure --profile sbg-user
```

Se te pedirá lo siguiente (usa los valores del JSON del paso anterior):

```
AWS Access Key ID [None]: <AccessKeyId del JSON>
AWS Secret Access Key [None]: <SecretAccessKey del JSON>
Default region name [None]: us-east-1
Default output format [None]: json
```

**Verificar que el perfil quedó bien configurado**

```bash
aws sts get-caller-identity --profile sbg-user
```

(Debería mostrar el ARN de `sbg-student-test`, no el de tu usuario administrador)

### 3 - Intentar listar o subir archivos usando el nuevo perfil

```bash
aws s3 cp archivo_test.txt s3://$BUCKET_NAME/ --profile sbg-user
```

(Verifica que el resultado sea `AccessDenied`. AWS sigue el principio de *Deny by default*)

### 4 - Implementar la política de acceso (PoLP)

**Crear una variable con el ARN del usuario**

```bash
export USER_ARN=$(aws iam get-user --user-name sbg-student-test --query 'User.Arn' --output text)
```

**Crear el archivo `policy.json` con el siguiente contenido**

```bash
cat <<EOF > policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "$USER_ARN"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::$BUCKET_NAME/*"
      ]
    }
  ]
}
EOF
```

**Aplicar la política al bucket**

```bash
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://policy.json
```

### 5 - Repetir el comando de subida

```bash
aws s3 cp archivo_test.txt s3://$BUCKET_NAME/ --profile sbg-user
```

(El archivo debería subirse correctamente)

### 6 - Auditoría con CloudTrail

- Ingresar a la consola de AWS → CloudTrail → Event history
- Filtrar por *resource name* ingresando el valor de la variable `$BUCKET_NAME` (ej. `sbg-uach-test-lab-2026-jperez`) y confirmar el registro de los eventos `CreateBucket` y `PutBucketPolicy`.

### 7 - Limpieza de recursos

**Eliminar la política del bucket**

```bash
aws s3api delete-bucket-policy --bucket $BUCKET_NAME
```

**Vaciar y eliminar el bucket**

```bash
aws s3 rb s3://$BUCKET_NAME --force
```

**Eliminar las claves de acceso del usuario** (se necesita el `AccessKeyId` del paso 2)

```bash
aws iam delete-access-key --user-name sbg-student-test --access-key-id <AccessKeyId>
```

**Eliminar el usuario IAM**

```bash
aws iam delete-user --user-name sbg-student-test
```

**Verificar que no queden recursos huérfanos**

```bash
aws s3 ls | grep sbg-uach-test-lab
aws iam list-users | grep sbg-student-test
```

(Ambos comandos no deberían devolver resultados)

## Recomendaciones de seguridad

- **Principio de Privilegio Mínimo (PoLP)**
  - Nunca otorgues permisos de administrador (`AdministratorAccess`) para tareas de usuario final
- **Bloqueo del acceso público**
  - En producción, siempre activa "Block Public Access" en los buckets S3
- **Rotación de claves**
  - Las claves de acceso deben rotarse periódicamente; prefiere el uso de roles IAM (IAM Roles) siempre que sea posible
- **Logging**
  - Mantén CloudTrail habilitado en todas las regiones para tener visibilidad total de quién hizo qué y cuándo
