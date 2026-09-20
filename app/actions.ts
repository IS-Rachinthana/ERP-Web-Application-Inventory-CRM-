"use server";

import { Currency, Segment } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/prisma";
import { issueInvoice, receiveGoods } from "@/lib/operations";

const value = (f: FormData, k: string) => String(f.get(k) ?? "").trim();
const numeric = (f: FormData, k: string) => Number(value(f, k));
const complete = (message: string) => { revalidatePath("/"); redirect(`/?message=${encodeURIComponent(message)}`); };
const fail = (e: unknown) => redirect(`/?error=${encodeURIComponent(e instanceof Error ? e.message : "Unable to save record.")}`);

export async function createProduct(f: FormData) { try { const sellingPrice = numeric(f,"sellingPrice"); await prisma.product.create({ data: { sku: value(f,"sku"), name: value(f,"name"), price: sellingPrice, description: value(f,"description") || null, costPrice: numeric(f,"costPrice"), sellingPrice, reorderLevel: Math.max(0, Math.floor(numeric(f,"reorderLevel"))) } }); complete("Product added."); } catch(e) { fail(e); } }
export async function createSupplier(f: FormData) { try { await prisma.supplier.create({ data: { name:value(f,"name"), country:value(f,"country")||null, contactName:value(f,"contactName")||null, email:value(f,"email")||null, phone:value(f,"phone")||null } }); complete("Supplier added."); } catch(e) { fail(e); } }
export async function createCustomer(f: FormData) { try { await prisma.customer.create({ data: { name:value(f,"name"), segment:(value(f,"segment") || "RETAIL") as Segment, country:value(f,"country")||null, email:value(f,"email")||null, phone:value(f,"phone")||null } }); complete("Customer added."); } catch(e) { fail(e); } }
export async function createGrn(f: FormData) { try { await receiveGoods(prisma, { supplierId:value(f,"supplierId")||undefined, currency:(value(f,"currency")||"USD") as Currency, ratePerUsd:numeric(f,"ratePerUsd"), lines:[{productId:value(f,"productId"),quantity:Math.floor(numeric(f,"quantity")),unitPrice:numeric(f,"unitPrice")}] }); complete("Goods received and stock updated."); } catch(e) { fail(e); } }
export async function createInvoice(f: FormData) { try { await issueInvoice(prisma, { customerId:value(f,"customerId")||undefined, currency:(value(f,"currency")||"USD") as Currency, ratePerUsd:numeric(f,"ratePerUsd"), lines:[{productId:value(f,"productId"),quantity:Math.floor(numeric(f,"quantity")),unitPrice:numeric(f,"unitPrice")}] }); complete("Invoice issued and stock reduced."); } catch(e) { fail(e); } }
