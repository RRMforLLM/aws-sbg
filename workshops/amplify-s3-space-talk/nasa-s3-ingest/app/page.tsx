"use client";

import { ChangeEvent, useState } from "react";

const MAX_SINGLE_PUT_BYTES = 5 * 1024 ** 3; // Límite de S3 para un solo PUT: 5 GB

type Status =
  | { kind: "idle" }
  | { kind: "signing" }
  | { kind: "uploading"; percent: number }
  | { kind: "done"; key: string; seconds: number; mbPerSecond: number }
  | { kind: "error"; message: string };

function putToS3(url: string, file: File, contentType: string, onProgress: (percent: number) => void) {
  // XMLHttpRequest en vez de fetch porque fetch no reporta progreso de subida.
  return new Promise<void>((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open("PUT", url);
    xhr.setRequestHeader("Content-Type", contentType);
    xhr.upload.onprogress = (event) => {
      if (event.lengthComputable) onProgress(Math.round((event.loaded / event.total) * 100));
    };
    xhr.onload = () =>
      xhr.status >= 200 && xhr.status < 300
        ? resolve()
        : reject(new Error(`S3 respondió ${xhr.status}: ${xhr.responseText.slice(0, 300)}`));
    // El navegador oculta los detalles de un bloqueo CORS: aquí solo llega "error de red".
    xhr.onerror = () => reject(new Error("La subida a S3 falló. Si la consola muestra un error de CORS, revisa la configuración CORS del bucket."));
    xhr.send(file);
  });
}

export default function Home() {
  const [file, setFile] = useState<File | null>(null);
  const [status, setStatus] = useState<Status>({ kind: "idle" });
  const busy = status.kind === "signing" || status.kind === "uploading";

  function onFileChange(event: ChangeEvent<HTMLInputElement>) {
    setFile(event.target.files?.[0] ?? null);
    setStatus({ kind: "idle" });
  }

  async function upload() {
    if (!file) return;
    if (file.size > MAX_SINGLE_PUT_BYTES) {
      setStatus({ kind: "error", message: "El archivo supera 5 GB, el máximo de S3 para un solo PUT." });
      return;
    }

    try {
      // 1. Pedir permiso a la API: aquí solo viajan el nombre y el tipo.
      setStatus({ kind: "signing" });
      const params = new URLSearchParams({
        filename: file.name,
        contentType: file.type || "application/octet-stream",
      });
      const response = await fetch(`/api/upload?${params}`);
      const data = await response.json();
      if (!response.ok) throw new Error(data.error ?? `La API respondió ${response.status}`);

      // 2. Subir directo a S3, sin pasar por el servidor.
      const startedAt = performance.now();
      setStatus({ kind: "uploading", percent: 0 });
      await putToS3(data.url, file, data.contentType, (percent) => setStatus({ kind: "uploading", percent }));

      const seconds = (performance.now() - startedAt) / 1000;
      setStatus({ kind: "done", key: data.key, seconds, mbPerSecond: file.size / 1024 ** 2 / seconds });
    } catch (error) {
      setStatus({ kind: "error", message: error instanceof Error ? error.message : "Error desconocido" });
    }
  }

  return (
    <main style={{ maxWidth: 560, margin: "0 auto", padding: "64px 16px" }}>
      <h1 style={{ marginBottom: 8 }}>Ingesta de datasets NASA</h1>
      <p style={{ color: "#9da7b3", marginTop: 0 }}>El archivo viaja directo del navegador a Amazon S3.</p>

      <input type="file" onChange={onFileChange} disabled={busy} style={{ display: "block", margin: "24px 0" }} />
      {file && <p>{file.name} ({(file.size / 1024 ** 2).toFixed(1)} MB)</p>}

      <button
        onClick={upload}
        disabled={!file || busy}
        style={{ padding: "10px 20px", fontSize: 16, cursor: !file || busy ? "not-allowed" : "pointer" }}
      >
        {busy ? "Subiendo..." : "Subir a S3"}
      </button>

      <div aria-live="polite" style={{ marginTop: 24 }}>
        {status.kind === "signing" && <p>Solicitando URL prefirmada...</p>}
        {status.kind === "uploading" && (
          <>
            <progress value={status.percent} max={100} style={{ width: "100%" }} />
            <p>{status.percent}%</p>
          </>
        )}
        {status.kind === "done" && (
          <p style={{ color: "#3fb950", overflowWrap: "anywhere" }}>
            Subida completa en {status.seconds.toFixed(1)} s ({status.mbPerSecond.toFixed(1)} MB/s).<br />
            Objeto: <code>{status.key}</code>
          </p>
        )}
        {status.kind === "error" && <p style={{ color: "#f85149", overflowWrap: "anywhere" }}>{status.message}</p>}
      </div>
    </main>
  );
}
