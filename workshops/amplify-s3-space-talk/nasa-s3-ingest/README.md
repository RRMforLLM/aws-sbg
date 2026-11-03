# Ingesta de datos NASA a S3

Boilerplate para subir archivos pesados directo del navegador a Amazon S3 con URLs prefirmadas. Stack: Next.js (App Router), AWS Amplify y Amazon S3.

## Flujo de datos

1. `app/page.tsx` pide permiso con `GET /api/upload?filename=...&contentType=...`.
2. `app/api/upload/route.ts` genera una URL temporal de 15 minutos con `PutObjectCommand` y `getSignedUrl`.
3. `app/page.tsx` sube el archivo con un `PUT` directo a esa URL. El archivo no pasa por el servidor.

Máximo por archivo: 5 GB, el límite de S3 para un solo `PUT`.

## Configuración

### Variables de entorno en Amplify

Agrégalas antes de compilar. Amplify no permite variables con el prefijo `AWS`, y `amplify.yml` las copia a `.env.production` para que Next.js pueda leerlas en el servidor.

| Variable | Valor |
| --- | --- |
| `S3_BUCKET_NAME` | Nombre del bucket |
| `S3_REGION` | Región del bucket, ej. `us-east-1` |
| `S3_ACCESS_KEY_ID` | Access key del usuario IAM |
| `S3_SECRET_ACCESS_KEY` | Secret access key del usuario IAM |

Cualquier cambio en estas variables requiere un nuevo despliegue.

### CORS del bucket

Plantilla: [`config/s3-cors.json`](config/s3-cors.json). Reemplaza `<APP_ID>` y pégala en S3 > tu bucket > Permissions > Cross-origin resource sharing (CORS).

### Política IAM inline

Plantilla: [`config/iam-inline-policy.json`](config/iam-inline-policy.json). Reemplaza `<NOMBRE_DEL_BUCKET>` y agrégala al usuario de la API.

## Desarrollo local

```bash
cp .env.example .env.local   # y completa los valores
npm install
npm run dev
```

Requiere Node.js 20 o superior.

## Bloqueos de IAM y CORS

Firmar una URL no contacta a AWS, así que unas credenciales incorrectas fallan en el `PUT`, no en la API.

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| La compilación falla en `env \| grep` | No hay variables `S3_*` en Amplify | Agrégalas y vuelve a desplegar |
| `Faltan variables de entorno` | Falta una variable, o se agregó después de compilar | Corrígela y vuelve a desplegar |
| Error de CORS en el navegador | El bucket no tiene CORS, o el origen no coincide | Usa el dominio exacto, con `https://` y sin `/` final |
| `403 AccessDenied` | La política no cubre el bucket o `uploads/*` | Revisa el `Resource` de la política |
| `403 InvalidAccessKeyId` | Access key incorrecta o eliminada | Corrige `S3_ACCESS_KEY_ID` y vuelve a desplegar |
| `403 SignatureDoesNotMatch` | Secret incorrecto | Corrige `S3_SECRET_ACCESS_KEY` y vuelve a desplegar |
| `Request has expired` | Pasaron más de 15 minutos | Intenta de nuevo para obtener otra URL |
| Redirección o CORS según la región | `S3_REGION` no es la región del bucket | Usa la región exacta y vuelve a desplegar |

## Simulacro de despliegue

Pendiente: completar tras ejecutarlo en una cuenta AWS limpia.

| Etapa | Tiempo medido |
| --- | --- |
| Bucket y usuario IAM | |
| Copia del repositorio y primera compilación | |
| Diagnóstico y corrección de CORS | |
| Subida de 176 MB | |

Bloqueos encontrados: pendiente.

## Antes de usar en producción

Este repositorio es material de laboratorio. La API es pública y usa claves de acceso de larga duración. En producción, exige autenticación, usa un rol IAM para el cómputo y limita el tamaño de los archivos.
