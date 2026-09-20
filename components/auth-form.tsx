"use client";

import { useState } from "react";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";

export function AuthForm() {
  const [mode, setMode] = useState<"login" | "signup" | "reset">("login");
  const [message, setMessage] = useState("");
  async function submit(formData: FormData) {
    const email = String(formData.get("email")); const password = String(formData.get("password"));
    const supabase = createSupabaseBrowserClient(); setMessage("");
    if (mode === "reset") { const { error } = await supabase.auth.resetPasswordForEmail(email, { redirectTo: `${window.location.origin}/login` }); setMessage(error?.message ?? "Password reset instructions have been sent."); return; }
    const result = mode === "login" ? await supabase.auth.signInWithPassword({ email, password }) : await supabase.auth.signUp({ email, password, options: { data: { full_name: String(formData.get("name") || "") } } });
    if (result.error) { setMessage(result.error.message); return; }
    if (mode === "signup") { setMessage("Account created. Confirm your email if Supabase requests it, then log in."); setMode("login"); return; }
    window.location.assign("/");
  }
  return <div className="w-full max-w-md rounded-3xl border border-slate-200 bg-white p-8 shadow-2xl shadow-slate-900/10"><div className="mb-8"><p className="text-sm font-semibold text-indigo-600">STOCKWISE ERP</p><h1 className="mt-2 text-3xl font-bold tracking-tight text-slate-950">{mode === "login" ? "Welcome back" : mode === "signup" ? "Create your owner account" : "Reset your password"}</h1><p className="mt-2 text-sm text-slate-500">Use your email as your username.</p></div><form action={submit} className="space-y-4">{mode === "signup" && <label className="block text-sm font-medium text-slate-700">Full name<input name="name" required className="mt-1 w-full rounded-xl border border-slate-300 px-3 py-2.5 outline-none ring-indigo-500 focus:ring-2" /></label>}<label className="block text-sm font-medium text-slate-700">Email<input name="email" type="email" required className="mt-1 w-full rounded-xl border border-slate-300 px-3 py-2.5 outline-none ring-indigo-500 focus:ring-2" /></label>{mode !== "reset" && <label className="block text-sm font-medium text-slate-700">Password<input name="password" type="password" minLength={6} required className="mt-1 w-full rounded-xl border border-slate-300 px-3 py-2.5 outline-none ring-indigo-500 focus:ring-2" /></label>}<button className="w-full rounded-xl bg-indigo-600 px-4 py-3 font-semibold text-white transition hover:bg-indigo-500">{mode === "login" ? "Sign in" : mode === "signup" ? "Create account" : "Send reset link"}</button></form>{message && <p className="mt-4 rounded-xl bg-slate-100 p-3 text-sm text-slate-700">{message}</p>}<div className="mt-6 flex flex-wrap gap-x-4 gap-y-2 text-sm"><button onClick={() => setMode(mode === "login" ? "signup" : "login")} className="font-semibold text-indigo-600">{mode === "login" ? "Create first account" : "Back to login"}</button>{mode === "login" && <button onClick={() => setMode("reset")} className="font-semibold text-slate-500">Forgot password?</button>}</div></div>;
}
