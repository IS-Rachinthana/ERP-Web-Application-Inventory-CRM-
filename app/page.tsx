import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { AppSidebar } from "@/components/app-sidebar";
import { signOut } from "./auth/actions";

export const dynamic = "force-dynamic";

export default async function Dashboard() {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const [storedProfile, products, suppliers, customers, invoices, company] = await Promise.all([
    prisma.profile.findUnique({ where: { id: user.id } }),
    prisma.product.count(), prisma.supplier.count(), prisma.customer.count(), prisma.invoice.count(),
    prisma.companySetting.findFirst(),
  ]);
  let profile = storedProfile;
  if (!profile) {
    const isFirstAccount = (await prisma.profile.count()) === 0;
    profile = await prisma.profile.create({ data: { id: user.id, email: user.email ?? "", fullName: (user.user_metadata.full_name as string | undefined) ?? null, role: isFirstAccount ? "OWNER" : "STOREKEEPER" } });
  }
  if (!profile.isActive) return <main className="grid min-h-screen place-items-center p-6"><div className="rounded-2xl border bg-white p-8 text-center shadow"><h1 className="text-xl font-bold">Account awaiting activation</h1><p className="mt-2 text-sm text-slate-500">Ask an owner or administrator to activate your account.</p><form action={signOut}><button className="mt-5 rounded-lg bg-slate-900 px-4 py-2 text-sm font-semibold text-white">Sign out</button></form></div></main>;
  const metrics = [["Products", products, "Catalogued items"], ["Suppliers", suppliers, "Approved partners"], ["Customers", customers, "CRM contacts"], ["Invoices", invoices, "Issued documents"]];
  return <div className="min-h-screen bg-slate-50 lg:grid lg:grid-cols-[264px_1fr]"><AppSidebar active="dashboard" name={profile.fullName || user.email || "Account"} role={profile.role} companyName={company?.name}/><main className="p-5 sm:p-8 lg:p-10"><header className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center"><div><p className="text-sm font-semibold text-indigo-600">V1 + V2 · LIVE WORKSPACE</p><h1 className="mt-1 text-3xl font-bold tracking-tight text-slate-950">Good morning, {profile.fullName?.split(" ")[0] || "there"}.</h1><p className="mt-2 text-sm text-slate-500">Your secure workspace is ready for catalogue and supplier operations.</p></div><div className="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm shadow-sm"><span className="mr-2 inline-block size-2 rounded-full bg-emerald-500"/>Supabase connected</div></header><section className="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">{metrics.map(([label, value, note]) => <article key={String(label)} className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm"><p className="text-sm font-medium text-slate-500">{label}</p><p className="mt-3 text-3xl font-bold tracking-tight text-slate-950">{value}</p><p className="mt-2 text-xs text-slate-400">{note}</p></article>)}</section><section className="mt-8 grid gap-6 xl:grid-cols-[1.4fr_1fr]"><article className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm"><div className="flex items-center justify-between"><div><p className="text-sm font-semibold text-slate-950">Release readiness</p><p className="mt-1 text-sm text-slate-500">Security controls and V2 master data are active.</p></div><span className="rounded-full bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-700">SECURE</span></div><div className="mt-7 grid gap-3 sm:grid-cols-2">{[["Authentication", "Supabase email and password login"], ["Role access", "Operational access is enforced"], ["Catalogue", "Products, variants and price levels"], ["Supplier register", "Contacts, brands and tax duplicate checks"]].map(([title, text]) => <div key={title} className="rounded-xl bg-slate-50 p-4"><p className="font-semibold text-slate-800">{title}</p><p className="mt-1 text-sm text-slate-500">{text}</p></div>)}</div></article><article id="roadmap" className="rounded-2xl bg-indigo-600 p-6 text-white shadow-lg shadow-indigo-200"><p className="text-sm font-semibold text-indigo-100">CURRENT RELEASE</p><h2 className="mt-2 text-2xl font-bold">V2 Catalogue & Suppliers</h2><p className="mt-3 text-sm leading-6 text-indigo-100">Open the Catalogue or Suppliers section to create and manage V2 master data.</p><div className="mt-6 flex gap-3"><a href="/catalogue" className="rounded-lg bg-white px-3 py-2 text-sm font-bold text-indigo-700">Catalogue</a><a href="/suppliers" className="rounded-lg bg-white/15 px-3 py-2 text-sm font-bold text-white">Suppliers</a></div></article></section></main></div>;
}
