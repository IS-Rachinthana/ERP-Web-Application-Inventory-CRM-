import { Currency, Prisma, PrismaClient } from "@prisma/client";

type Line = { productId: string; quantity: number; unitPrice: number };
type Tx = Prisma.TransactionClient;
async function nextNumber(tx: Tx, prefix: "GRN" | "INV") { const c = await tx.docCounter.upsert({ where: { key: prefix }, create: { key: prefix, value: 1 }, update: { value: { increment: 1 } } }); return `${prefix}-${String(c.value).padStart(6, "0")}`; }

export async function receiveGoods(prisma: PrismaClient, input: { supplierId?: string; currency: Currency; ratePerUsd: number; lines: Line[] }) {
  return prisma.$transaction(async tx => { const number = await nextNumber(tx, "GRN"); const grn = await tx.grn.create({ data: { number, supplierId: input.supplierId, currency: input.currency, ratePerUsd: input.ratePerUsd } });
    for (const l of input.lines) { if (!Number.isInteger(l.quantity) || l.quantity <= 0 || l.unitPrice < 0) throw new Error("Use a positive quantity and valid cost."); await tx.grnItem.create({ data: { grnId: grn.id, productId: l.productId, quantity: l.quantity, unitCost: l.unitPrice } }); await tx.product.update({ where: { id: l.productId }, data: { quantityOnHand: { increment: l.quantity }, costPrice: l.unitPrice / input.ratePerUsd } }); await tx.stockLedger.create({ data: { productId: l.productId, type: "GRN", quantity: l.quantity, refType: "GRN", refId: grn.id, note: `Goods received ${number}` } }); }
    return grn;
  });
}
export async function issueInvoice(prisma: PrismaClient, input: { customerId?: string; currency: Currency; ratePerUsd: number; lines: Line[] }) {
  return prisma.$transaction(async tx => { const number = await nextNumber(tx, "INV"); const invoice = await tx.invoice.create({ data: { number, customerId: input.customerId, currency: input.currency, ratePerUsd: input.ratePerUsd } });
    for (const l of input.lines) { if (!Number.isInteger(l.quantity) || l.quantity <= 0 || l.unitPrice < 0) throw new Error("Use a positive quantity and valid price."); const p = await tx.product.findUnique({ where: { id: l.productId }, select: { costPrice: true } }); if (!p) throw new Error("Product not found."); const changed = await tx.product.updateMany({ where: { id: l.productId, quantityOnHand: { gte: l.quantity } }, data: { quantityOnHand: { decrement: l.quantity } } }); if (changed.count !== 1) throw new Error("Insufficient stock; invoice was not saved."); await tx.invoiceItem.create({ data: { invoiceId: invoice.id, productId: l.productId, quantity: l.quantity, unitPrice: l.unitPrice, costPriceAtSale: p.costPrice } }); await tx.stockLedger.create({ data: { productId: l.productId, type: "GDN", quantity: -l.quantity, refType: "INVOICE", refId: invoice.id, note: `Invoice ${number}` } }); }
    return invoice;
  });
}
