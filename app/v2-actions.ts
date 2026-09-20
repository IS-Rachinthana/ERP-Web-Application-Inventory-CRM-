"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { Prisma } from "@prisma/client";
import { prisma } from "@/lib/prisma";
import { createSupabaseServerClient } from "@/lib/supabase/server";

const productRoles = ["OWNER", "ADMIN", "MANAGER", "STOREKEEPER"] as const;
const supplierRoles = ["OWNER", "ADMIN", "MANAGER", "ACCOUNTANT"] as const;

async function actor(allowed: readonly string[]) {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const profile = await prisma.profile.findUnique({ where: { id: user.id } });
  if (!profile?.isActive || !allowed.includes(profile.role)) throw new Error("You do not have permission for this action.");
  return profile;
}

function required(value: FormDataEntryValue | null, label: string) {
  const result = String(value ?? "").trim();
  if (!result) throw new Error(`${label} is required.`);
  return result;
}

export async function createProduct(formData: FormData) {
  const profile = await actor(productRoles);
  const name = required(formData.get("name"), "Product name");
  const sku = required(formData.get("sku"), "Base SKU").toUpperCase();
  const type = String(formData.get("type"));
  const trackingMode = String(formData.get("trackingMode"));
  if (!["LAPTOP", "SPARE_PART", "ACCESSORY"].includes(type) || !["SERIAL", "QUANTITY"].includes(trackingMode)) throw new Error("Invalid product type or tracking mode.");
  const costPrice = new Prisma.Decimal(String(formData.get("costPrice") || "0"));
  const sellingPrice = new Prisma.Decimal(String(formData.get("sellingPrice") || "0"));
  const minimumOrderQuantity = Number(formData.get("minimumOrderQuantity") || 1);
  const maximumText = String(formData.get("maximumOrderQuantity") || "").trim();
  const maximumOrderQuantity = maximumText ? Number(maximumText) : null;
  if (!Number.isInteger(minimumOrderQuantity) || minimumOrderQuantity < 1 || (maximumOrderQuantity !== null && (!Number.isInteger(maximumOrderQuantity) || maximumOrderQuantity < minimumOrderQuantity))) throw new Error("Enter a valid minimum and maximum order quantity.");
  if (costPrice.isNegative() || sellingPrice.isNegative()) throw new Error("Prices cannot be negative.");
  let product;
  try {
  product = await prisma.$transaction(async (tx) => {
    const created = await tx.product.create({ data: {
      name, sku, type: type as "LAPTOP" | "SPARE_PART" | "ACCESSORY", trackingMode: trackingMode as "SERIAL" | "QUANTITY",
      description: String(formData.get("description") || "").trim() || null, price: sellingPrice, costPrice, sellingPrice,
      categoryId: String(formData.get("categoryId") || "") || null, brandId: String(formData.get("brandId") || "") || null,
      unitId: String(formData.get("unitId") || "") || null, taxRateId: String(formData.get("taxRateId") || "") || null,
      minimumOrderQuantity, maximumOrderQuantity,
      laptopSpec: type === "LAPTOP" ? { create: { cpu: String(formData.get("cpu") || "") || null, ram: String(formData.get("ram") || "") || null, storage: String(formData.get("storage") || "") || null, gpu: String(formData.get("gpu") || "") || null, screen: String(formData.get("screen") || "") || null, operatingSystem: String(formData.get("operatingSystem") || "") || null, condition: String(formData.get("condition") || "") || null } } : undefined,
      variants: { create: { sku, name: "Default" } },
      priceLevels: { create: [{ level: "RETAIL", amount: sellingPrice }, { level: "COST", amount: costPrice }] },
    } });
    await tx.auditLog.create({ data: { actorId: profile.id, action: "CREATE", entityType: "PRODUCT", entityId: created.id, detail: { sku, name } } });
    return created;
  });
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") redirect("/catalogue?error=A+product+with+that+SKU+already+exists.");
    redirect("/catalogue?error=The+product+could+not+be+saved.+Please+check+the+form+and+try+again.");
  }
  revalidatePath("/"); revalidatePath("/catalogue"); redirect(`/catalogue?created=${product.id}`);
}

export async function createSupplier(formData: FormData) {
  const profile = await actor(supplierRoles);
  const name = required(formData.get("name"), "Supplier name");
  const taxNumber = String(formData.get("taxNumber") || "").trim() || null;
  const brandIds = formData.getAll("brandIds").map(String).filter(Boolean);
  const supplier = await prisma.$transaction(async (tx) => {
    const created = await tx.supplier.create({ data: {
      name, taxNumber, country: String(formData.get("country") || "") || null, contactName: String(formData.get("contactName") || "") || null,
      email: String(formData.get("email") || "") || null, phone: String(formData.get("phone") || "") || null, address: String(formData.get("address") || "") || null,
      paymentTerms: String(formData.get("paymentTerms") || "") || null, status: String(formData.get("status")) === "INACTIVE" ? "INACTIVE" : "ACTIVE",
      contacts: String(formData.get("contactPerson") || "").trim() ? { create: { name: String(formData.get("contactPerson")), email: String(formData.get("contactEmail") || "") || null, phone: String(formData.get("contactPhone") || "") || null } } : undefined,
      bankAccounts: String(formData.get("bankName") || "").trim() && String(formData.get("accountNumber") || "").trim() ? { create: { bankName: String(formData.get("bankName")), accountName: String(formData.get("accountName") || "") || null, accountNumber: String(formData.get("accountNumber")) } } : undefined,
      brands: brandIds.length ? { create: brandIds.map((brandId) => ({ brandId })) } : undefined,
    } });
    await tx.auditLog.create({ data: { actorId: profile.id, action: "CREATE", entityType: "SUPPLIER", entityId: created.id, detail: { name, taxNumber } } });
    return created;
  });
  revalidatePath("/"); revalidatePath("/suppliers"); redirect(`/suppliers?created=${supplier.id}`);
}

export async function createCategory(formData: FormData) {
  await actor(["OWNER", "ADMIN", "MANAGER"]);
  const name = required(formData.get("name"), "Category name");
  await prisma.category.create({ data: { name, parentId: String(formData.get("parentId") || "") || null } });
  revalidatePath("/catalogue"); redirect("/catalogue?notice=Category+saved+successfully.");
}

export async function createBrand(formData: FormData) {
  await actor(["OWNER", "ADMIN", "MANAGER"]);
  await prisma.brand.create({ data: { name: required(formData.get("name"), "Brand name") } });
  revalidatePath("/catalogue"); revalidatePath("/suppliers"); redirect("/catalogue?notice=Brand+saved+successfully.");
}

export async function createUnit(formData: FormData) {
  await actor(["OWNER", "ADMIN", "MANAGER"]);
  const name = required(formData.get("name"), "Unit name");
  const symbol = required(formData.get("symbol"), "Unit symbol").toUpperCase();
  await prisma.unit.create({ data: { name, symbol } });
  revalidatePath("/catalogue"); redirect("/catalogue?notice=Unit+saved+successfully.");
}
