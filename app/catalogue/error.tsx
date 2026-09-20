"use client";

export default function CatalogueError({ reset }: { reset: () => void }) {
  return <main className="grid min-h-screen place-items-center bg-slate-50 p-6"><section className="max-w-md rounded-2xl border border-rose-200 bg-white p-7 text-center shadow-sm"><p className="text-sm font-bold text-rose-600">CATALOGUE ERROR</p><h1 className="mt-2 text-2xl font-bold text-slate-950">We could not save that record</h1><p className="mt-3 text-sm leading-6 text-slate-600">Check required fields and unique values, then try again. Nothing was partially saved.</p><button onClick={reset} className="mt-6 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-bold text-white">Return to catalogue</button></section></main>;
}
