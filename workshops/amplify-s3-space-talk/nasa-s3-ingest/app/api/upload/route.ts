import { randomUUID } from "node:crypto";
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { NextRequest, NextResponse } from "next/server";

export const dynamic = "force-dynamic";

const URL_EXPIRY_SECONDS = 900; // 15 minutos
const REQUIRED_ENV = ["S3_BUCKET_NAME", "S3_REGION", "S3_ACCESS_KEY_ID", "S3_SECRET_ACCESS_KEY"] as const;
const NO_STORE = { "Cache-Control": "no-store" };

export async function GET(request: NextRequest) {
  // Reporta solo los nombres de lo que falta, nunca los valores.
  const missing = REQUIRED_ENV.filter((name) => !process.env[name]);
  if (missing.length > 0) {
    return NextResponse.json(
      { error: `Faltan variables de entorno: ${missing.join(", ")}` },
      { status: 500, headers: NO_STORE },
    );
  }

  const filename = request.nextUrl.searchParams.get("filename");
  const contentType = request.nextUrl.searchParams.get("contentType") || "application/octet-stream";
  if (!filename) {
    return NextResponse.json({ error: "Falta el parámetro filename" }, { status: 400, headers: NO_STORE });
  }

  const s3 = new S3Client({
    region: process.env.S3_REGION,
    credentials: {
      accessKeyId: process.env.S3_ACCESS_KEY_ID!,
      secretAccessKey: process.env.S3_SECRET_ACCESS_KEY!,
    },
    // Sin esto, el SDK firma el checksum de un cuerpo vacío dentro de la URL.
    requestChecksumCalculation: "WHEN_REQUIRED",
  });

  // El servidor decide la ruta: el cliente no puede escribir fuera de uploads/
  // ni sobrescribir el archivo de otra persona.
  const safeName = filename.replace(/[^a-zA-Z0-9._-]/g, "_").slice(-100);
  const key = `uploads/${randomUUID()}-${safeName}`;

  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: key,
    ContentType: contentType,
  });

  try {
    const url = await getSignedUrl(s3, command, { expiresIn: URL_EXPIRY_SECONDS });
    return NextResponse.json({ url, key, contentType }, { headers: NO_STORE });
  } catch (error) {
    console.error("No se pudo generar la URL prefirmada", error);
    return NextResponse.json({ error: "No se pudo generar la URL" }, { status: 500, headers: NO_STORE });
  }
}
