import Link from "next/link";

export function V2Nav({ active }: { active: "catalogue" | "suppliers" }) {
  return <nav className="flex flex-wrap gap-2 border-b border-slate-200 pb-5 text-sm font-semibold">
    <Link href="/" className="rounded-lg px-3 py-2 text-slate-600 hover:bg-slate-100">Dashboard</Link>
    <Link href="/catalogue" className={`rounded-lg px-3 py-2 ${active === "catalogue" ? "bg-indigo-600 text-white" : "text-slate-600 hover:bg-slate-100"}`}>Catalogue</Link>
    <Link href="/suppliers" className={`rounded-lg px-3 py-2 ${active === "suppliers" ? "bg-indigo-600 text-white" : "text-slate-600 hover:bg-slate-100"}`}>Suppliers</Link>
  </nav>;
}
