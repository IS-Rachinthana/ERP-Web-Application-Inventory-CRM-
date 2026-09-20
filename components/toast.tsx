"use client";

import { useEffect, useState } from "react";

export function Toast({ message, kind = "success" }: { message?: string; kind?: "success" | "error" }) {
  const [visible, setVisible] = useState(Boolean(message));
  useEffect(() => { if (!message) return; const timeout = setTimeout(() => setVisible(false), 3500); return () => clearTimeout(timeout); }, [message]);
  if (!message || !visible) return null;
  return <div role={kind === "error" ? "alert" : "status"} className={`fixed right-5 top-5 z-50 max-w-sm rounded-xl px-4 py-3 text-sm font-semibold text-white shadow-xl ${kind === "error" ? "bg-rose-600" : "bg-emerald-600"}`}>{message}</div>;
}
