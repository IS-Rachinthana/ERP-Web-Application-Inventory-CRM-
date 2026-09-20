import Link from "next/link";
import { signOut } from "@/app/auth/actions";

type Props = { active: "dashboard" | "catalogue" | "suppliers"; name: string; role: string; companyName?: string | null };

export function AppSidebar({ active, name, role, companyName }: Props) {
  const links = [["dashboard", "Dashboard", "/"], ["catalogue", "Catalogue", "/catalogue"], ["suppliers", "Suppliers", "/suppliers"], ["inventory", "Inventory", "/#roadmap"], ["customers", "Customers", "/#roadmap"], ["sales", "Sales", "/#roadmap"], ["reports", "Reports", "/#roadmap"]] as const;
  return <aside className="flex min-h-full flex-col bg-slate-950 px-5 py-6 text-slate-300"><Link href="/" className="mb-10 flex items-center gap-3 px-2"><span className="grid size-10 place-items-center rounded-xl bg-indigo-500 font-black text-white">S</span><span><b className="block text-sm text-white">{companyName || "Stockwise ERP"}</b><span className="text-xs text-slate-500">Inventory & CRM</span></span></Link><nav className="space-y-1">{links.map(([key, label, href]) => <Link key={key} href={href} className={`flex rounded-xl px-3 py-2.5 text-sm font-medium transition ${active === key ? "bg-indigo-500 text-white" : "hover:bg-slate-800 hover:text-white"}`}>{label}</Link>)}</nav><div className="mt-auto rounded-2xl bg-slate-900 p-4"><p className="text-xs font-semibold text-white">{name}</p><p className="mt-1 text-xs uppercase tracking-wider text-indigo-300">{role.replaceAll("_", " ")}</p><form action={signOut}><button className="mt-4 text-xs font-semibold text-slate-400 hover:text-white">Sign out</button></form></div></aside>;
}
