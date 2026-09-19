-- Extends the starter schema while preserving legacy rows.
CREATE TYPE "Role" AS ENUM ('ADMIN', 'STAFF');
CREATE TYPE "Segment" AS ENUM ('RETAIL', 'WHOLESALE');
CREATE TYPE "Currency" AS ENUM ('USD', 'AED', 'LKR');
CREATE TYPE "LedgerType" AS ENUM ('GRN', 'GDN', 'ADJUSTMENT');
ALTER TABLE "Customer" ADD COLUMN "segment" "Segment" NOT NULL DEFAULT 'RETAIL', ADD COLUMN "country" TEXT, ADD COLUMN "address" TEXT;
ALTER TABLE "Product" ADD COLUMN "description" TEXT, ADD COLUMN "costPrice" DECIMAL(14,4) NOT NULL DEFAULT 0, ADD COLUMN "sellingPrice" DECIMAL(14,4) NOT NULL DEFAULT 0, ADD COLUMN "quantityOnHand" INTEGER NOT NULL DEFAULT 0, ADD COLUMN "reorderLevel" INTEGER NOT NULL DEFAULT 0;
UPDATE "Product" SET "sellingPrice" = "price", "quantityOnHand" = "quantity";

CREATE TABLE "User" ("id" TEXT NOT NULL, "email" TEXT NOT NULL, "name" TEXT NOT NULL, "passwordHash" TEXT NOT NULL, "role" "Role" NOT NULL DEFAULT 'STAFF', "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "User_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE TABLE "Supplier" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "country" TEXT, "contactName" TEXT, "email" TEXT, "phone" TEXT, "address" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Supplier_pkey" PRIMARY KEY ("id"));
CREATE TABLE "ExchangeRate" ("currency" "Currency" NOT NULL, "ratePerUsd" DECIMAL(18,6) NOT NULL, "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "ExchangeRate_pkey" PRIMARY KEY ("currency"));
INSERT INTO "ExchangeRate" ("currency", "ratePerUsd") VALUES ('USD',1),('AED',3.6725),('LKR',300) ON CONFLICT ("currency") DO NOTHING;
CREATE TABLE "DocCounter" ("key" TEXT NOT NULL, "value" INTEGER NOT NULL DEFAULT 0, CONSTRAINT "DocCounter_pkey" PRIMARY KEY ("key"));

CREATE TABLE "Grn" ("id" TEXT NOT NULL, "number" TEXT NOT NULL, "supplierId" TEXT, "currency" "Currency" NOT NULL DEFAULT 'USD', "ratePerUsd" DECIMAL(18,6) NOT NULL, "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "notes" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Grn_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "Grn_number_key" ON "Grn"("number"); CREATE INDEX "Grn_supplierId_idx" ON "Grn"("supplierId");
ALTER TABLE "Grn" ADD CONSTRAINT "Grn_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE SET NULL ON UPDATE CASCADE;
CREATE TABLE "GrnItem" ("id" TEXT NOT NULL, "grnId" TEXT NOT NULL, "productId" TEXT NOT NULL, "quantity" INTEGER NOT NULL, "unitCost" DECIMAL(14,4) NOT NULL, CONSTRAINT "GrnItem_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "GrnItem_grnId_productId_key" ON "GrnItem"("grnId","productId");
ALTER TABLE "GrnItem" ADD CONSTRAINT "GrnItem_grnId_fkey" FOREIGN KEY ("grnId") REFERENCES "Grn"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "GrnItem" ADD CONSTRAINT "GrnItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE TABLE "Invoice" ("id" TEXT NOT NULL, "number" TEXT NOT NULL, "customerId" TEXT, "currency" "Currency" NOT NULL DEFAULT 'USD', "ratePerUsd" DECIMAL(18,6) NOT NULL, "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "notes" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Invoice_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "Invoice_number_key" ON "Invoice"("number"); CREATE INDEX "Invoice_customerId_idx" ON "Invoice"("customerId");
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "Customer"("id") ON DELETE SET NULL ON UPDATE CASCADE;
CREATE TABLE "InvoiceItem" ("id" TEXT NOT NULL, "invoiceId" TEXT NOT NULL, "productId" TEXT NOT NULL, "quantity" INTEGER NOT NULL, "unitPrice" DECIMAL(14,4) NOT NULL, "costPriceAtSale" DECIMAL(14,4) NOT NULL, CONSTRAINT "InvoiceItem_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "InvoiceItem_invoiceId_productId_key" ON "InvoiceItem"("invoiceId","productId");
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
CREATE TABLE "StockLedger" ("id" TEXT NOT NULL, "productId" TEXT NOT NULL, "type" "LedgerType" NOT NULL, "quantity" INTEGER NOT NULL, "refType" TEXT NOT NULL, "refId" TEXT NOT NULL, "note" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "StockLedger_pkey" PRIMARY KEY ("id"));
CREATE INDEX "StockLedger_productId_idx" ON "StockLedger"("productId");
ALTER TABLE "StockLedger" ADD CONSTRAINT "StockLedger_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
