import type { ReactNode } from "react";

export const metadata = {
  title: "Ingesta NASA a S3",
  description: "Subida directa de datasets satelitales a Amazon S3 con URLs prefirmadas",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="es">
      <body style={{ margin: 0, background: "#0b1220", color: "#e6edf3", fontFamily: "system-ui, sans-serif" }}>
        {children}
      </body>
    </html>
  );
}
