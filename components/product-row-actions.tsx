"use client";

import Link from "next/link";
import { useState } from "react";
import { deleteProduct } from "@/app/v2-actions";

export function ProductRowActions({ id, canEdit, canDelete }: { id: string; canEdit: boolean; canDelete: boolean }) {
  const [open, setOpen] = useState(false);
  return <div className="relative"><button type="button" aria-label="Product actions" onClick={() => setOpen(!open)} className="rounded-lg px-2 py-1 text-xl font-bold leading-none text-slate-500 hover:bg-slate-100 hover:text-slate-950">⋮</button>{open && <div className="absolute bottom-full right-0 z-20 mb-1 w-32 rounded-xl border border-slate-200 bg-white p-1 shadow-lg"><Link href={`/catalogue/${id}`} className="block rounded-lg px-3 py-2 text-sm hover:bg-slate-50">View</Link>{canEdit && <Link href={`/catalogue?edit=${id}`} className="block rounded-lg px-3 py-2 text-sm hover:bg-slate-50">Edit</Link>}{canDelete && <form action={deleteProduct}><input type="hidden" name="id" value={id}/><button className="block w-full rounded-lg px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50">Delete</button></form>}</div>}</div>;
}
