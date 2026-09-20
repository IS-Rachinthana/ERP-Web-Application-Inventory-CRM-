import Link from "next/link";

export function V2Nav({ active }: { active: "catalogue" | "suppliers" }) {
  const links = [["Dashboard", "/"], ["Catalogue", "/catalogue"], ["Suppliers", "/suppliers"], ["Inventory", "/#roadmap"], ["Customers", "/#roadmap"], ["Sales", "/#roadmap"], ["Reports", "/#roadmap"]] as const;
  return <header className="-mx-5 -mt-5 mb-7 bg-slate-950 px-5 py-4 text-slate-300 sm:-mx-8 sm:-mt-8 sm:px-8"><div className="mx-auto flex max-w-7xl flex-col gap-4 lg:flex-row lg:items-center"><Link href="/" className="flex items-center gap-3"><span className="grid size-9 place-items-center rounded-lg bg-indigo-500 font-black text-white">S</span><span><b className="block text-sm text-white">Stockwise ERP</b><span className="text-xs text-slate-500">Inventory & CRM</span></span></Link><nav className="flex flex-wrap gap-1 lg:ml-auto">{links.map(([label, href]) => <Link key={label} href={href} className={`rounded-lg px-3 py-2 text-sm font-semibold ${label.toLowerCase() === active ? "bg-indigo-500 text-white" : "hover:bg-slate-800 hover:text-white"}`}>{label}</Link>)}</nav></div></header>;
}
