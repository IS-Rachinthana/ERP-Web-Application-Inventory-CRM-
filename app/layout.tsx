import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Stockwise ERP",
  description: "Inventory and customer relationship management"
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
