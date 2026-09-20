CREATE TYPE "ProductType" AS ENUM ('LAPTOP', 'SPARE_PART', 'ACCESSORY');
CREATE TYPE "TrackingMode" AS ENUM ('SERIAL', 'QUANTITY');
CREATE TYPE "SupplierStatus" AS ENUM ('ACTIVE', 'INACTIVE');

CREATE TABLE "Category" (
  "id" TEXT NOT NULL, "name" TEXT NOT NULL, "parentId" TEXT, "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "Category_name_parentId_key" ON "Category"("name", "parentId");
ALTER TABLE "Category" ADD CONSTRAINT "Category_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE "Brand" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "isActive" BOOLEAN NOT NULL DEFAULT true, CONSTRAINT "Brand_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "Brand_name_key" ON "Brand"("name");

ALTER TABLE "Product" ADD COLUMN "type" "ProductType" NOT NULL DEFAULT 'ACCESSORY', ADD COLUMN "trackingMode" "TrackingMode" NOT NULL DEFAULT 'QUANTITY', ADD COLUMN "categoryId" TEXT, ADD COLUMN "brandId" TEXT, ADD COLUMN "unitId" TEXT, ADD COLUMN "taxRateId" TEXT, ADD COLUMN "isActive" BOOLEAN NOT NULL DEFAULT true, ADD COLUMN "qrToken" UUID NOT NULL DEFAULT gen_random_uuid();
CREATE UNIQUE INDEX "Product_qrToken_key" ON "Product"("qrToken");
CREATE INDEX "Product_name_idx" ON "Product"("name");
ALTER TABLE "Product" ADD CONSTRAINT "Product_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Product" ADD CONSTRAINT "Product_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Product" ADD CONSTRAINT "Product_unitId_fkey" FOREIGN KEY ("unitId") REFERENCES "Unit"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Product" ADD CONSTRAINT "Product_taxRateId_fkey" FOREIGN KEY ("taxRateId") REFERENCES "TaxRate"("id") ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE "ProductVariant" ("id" TEXT NOT NULL, "productId" TEXT NOT NULL, "sku" TEXT NOT NULL, "name" TEXT, "attributes" JSONB, "isActive" BOOLEAN NOT NULL DEFAULT true, "qrToken" UUID NOT NULL DEFAULT gen_random_uuid(), CONSTRAINT "ProductVariant_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "ProductVariant_sku_key" ON "ProductVariant"("sku");
CREATE UNIQUE INDEX "ProductVariant_qrToken_key" ON "ProductVariant"("qrToken");
ALTER TABLE "ProductVariant" ADD CONSTRAINT "ProductVariant_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "LaptopSpec" ("productId" TEXT NOT NULL, "cpu" TEXT, "ram" TEXT, "storage" TEXT, "gpu" TEXT, "screen" TEXT, "operatingSystem" TEXT, "condition" TEXT, CONSTRAINT "LaptopSpec_pkey" PRIMARY KEY ("productId"));
ALTER TABLE "LaptopSpec" ADD CONSTRAINT "LaptopSpec_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "ProductImage" ("id" TEXT NOT NULL, "productId" TEXT NOT NULL, "path" TEXT NOT NULL, "altText" TEXT, "sortOrder" INTEGER NOT NULL DEFAULT 0, CONSTRAINT "ProductImage_pkey" PRIMARY KEY ("id"));
ALTER TABLE "ProductImage" ADD CONSTRAINT "ProductImage_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "ProductPrice" ("id" TEXT NOT NULL, "productId" TEXT NOT NULL, "level" TEXT NOT NULL, "amount" DECIMAL(14,4) NOT NULL, "minQuantity" INTEGER NOT NULL DEFAULT 1, "effectiveFrom" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "effectiveTo" TIMESTAMP(3), CONSTRAINT "ProductPrice_pkey" PRIMARY KEY ("id"));
CREATE INDEX "ProductPrice_productId_level_effectiveFrom_idx" ON "ProductPrice"("productId", "level", "effectiveFrom");
ALTER TABLE "ProductPrice" ADD CONSTRAINT "ProductPrice_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Supplier" ADD COLUMN "taxNumber" TEXT, ADD COLUMN "paymentTerms" TEXT, ADD COLUMN "status" "SupplierStatus" NOT NULL DEFAULT 'ACTIVE';
CREATE UNIQUE INDEX "Supplier_taxNumber_key" ON "Supplier"("taxNumber");
CREATE TABLE "SupplierContact" ("id" TEXT NOT NULL, "supplierId" TEXT NOT NULL, "name" TEXT NOT NULL, "email" TEXT, "phone" TEXT, "jobTitle" TEXT, CONSTRAINT "SupplierContact_pkey" PRIMARY KEY ("id"));
ALTER TABLE "SupplierContact" ADD CONSTRAINT "SupplierContact_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "SupplierBankAccount" ("id" TEXT NOT NULL, "supplierId" TEXT NOT NULL, "bankName" TEXT NOT NULL, "accountName" TEXT, "accountNumber" TEXT NOT NULL, CONSTRAINT "SupplierBankAccount_pkey" PRIMARY KEY ("id"));
ALTER TABLE "SupplierBankAccount" ADD CONSTRAINT "SupplierBankAccount_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "SupplierBrand" ("supplierId" TEXT NOT NULL, "brandId" TEXT NOT NULL, CONSTRAINT "SupplierBrand_pkey" PRIMARY KEY ("supplierId", "brandId"));
ALTER TABLE "SupplierBrand" ADD CONSTRAINT "SupplierBrand_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "SupplierBrand" ADD CONSTRAINT "SupplierBrand_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES "Brand"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "SupplierDocument" ("id" TEXT NOT NULL, "supplierId" TEXT NOT NULL, "path" TEXT NOT NULL, "name" TEXT NOT NULL, "mimeType" TEXT NOT NULL, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "SupplierDocument_pkey" PRIMARY KEY ("id"));
ALTER TABLE "SupplierDocument" ADD CONSTRAINT "SupplierDocument_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE CASCADE ON UPDATE CASCADE;
CREATE TABLE "ProductSupplier" ("productId" TEXT NOT NULL, "supplierId" TEXT NOT NULL, "supplierSku" TEXT, "lastPurchasePrice" DECIMAL(14,4), CONSTRAINT "ProductSupplier_pkey" PRIMARY KEY ("productId", "supplierId"));
ALTER TABLE "ProductSupplier" ADD CONSTRAINT "ProductSupplier_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProductSupplier" ADD CONSTRAINT "ProductSupplier_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES "Supplier"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE OR REPLACE FUNCTION public.v2_has_role(allowed "AppRole"[]) RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$ SELECT EXISTS (SELECT 1 FROM "Profile" WHERE id = auth.uid() AND "isActive" = true AND role = ANY(allowed)); $$;
ALTER TABLE "Product" ENABLE ROW LEVEL SECURITY; ALTER TABLE "Supplier" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Category" ENABLE ROW LEVEL SECURITY; ALTER TABLE "Brand" ENABLE ROW LEVEL SECURITY; ALTER TABLE "ProductVariant" ENABLE ROW LEVEL SECURITY; ALTER TABLE "LaptopSpec" ENABLE ROW LEVEL SECURITY; ALTER TABLE "ProductImage" ENABLE ROW LEVEL SECURITY; ALTER TABLE "ProductPrice" ENABLE ROW LEVEL SECURITY; ALTER TABLE "SupplierContact" ENABLE ROW LEVEL SECURITY; ALTER TABLE "SupplierBankAccount" ENABLE ROW LEVEL SECURITY; ALTER TABLE "SupplierBrand" ENABLE ROW LEVEL SECURITY; ALTER TABLE "SupplierDocument" ENABLE ROW LEVEL SECURITY; ALTER TABLE "ProductSupplier" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "v2_product_read" ON "Product" FOR SELECT TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','SALES_REP','STOREKEEPER','ACCOUNTANT','TECHNICIAN']::"AppRole"[]));
CREATE POLICY "v2_product_write" ON "Product" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[]));
CREATE POLICY "v2_supplier_read" ON "Supplier" FOR SELECT TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER','ACCOUNTANT']::"AppRole"[]));
CREATE POLICY "v2_supplier_write" ON "Supplier" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[]));
CREATE POLICY "v2_catalogue_read" ON "Category" FOR SELECT TO authenticated USING (true); CREATE POLICY "v2_catalogue_write" ON "Category" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER']::"AppRole"[]));
CREATE POLICY "v2_brand_read" ON "Brand" FOR SELECT TO authenticated USING (true); CREATE POLICY "v2_brand_write" ON "Brand" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER']::"AppRole"[]));
CREATE POLICY "v2_variant_read" ON "ProductVariant" FOR SELECT TO authenticated USING (true); CREATE POLICY "v2_variant_write" ON "ProductVariant" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[]));
CREATE POLICY "v2_specs_read" ON "LaptopSpec" FOR SELECT TO authenticated USING (true); CREATE POLICY "v2_specs_write" ON "LaptopSpec" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[]));
CREATE POLICY "v2_images_read" ON "ProductImage" FOR SELECT TO authenticated USING (true); CREATE POLICY "v2_images_write" ON "ProductImage" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER']::"AppRole"[]));
CREATE POLICY "v2_prices_read" ON "ProductPrice" FOR SELECT TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[])); CREATE POLICY "v2_prices_write" ON "ProductPrice" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER']::"AppRole"[]));
CREATE POLICY "v2_supplier_details" ON "SupplierContact" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','STOREKEEPER','ACCOUNTANT']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[]));
CREATE POLICY "v2_supplier_banks" ON "SupplierBankAccount" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[]));
CREATE POLICY "v2_supplier_brands" ON "SupplierBrand" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[]));
CREATE POLICY "v2_supplier_documents" ON "SupplierDocument" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[]));
CREATE POLICY "v2_product_suppliers" ON "ProductSupplier" FOR ALL TO authenticated USING (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[])) WITH CHECK (public.v2_has_role(ARRAY['OWNER','ADMIN','MANAGER','ACCOUNTANT']::"AppRole"[]));
