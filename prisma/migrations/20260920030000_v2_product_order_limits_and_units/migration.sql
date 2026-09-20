ALTER TABLE "Product" ADD COLUMN "minimumOrderQuantity" INTEGER NOT NULL DEFAULT 1, ADD COLUMN "maximumOrderQuantity" INTEGER;
ALTER TABLE "Product" ADD CONSTRAINT "Product_order_quantity_check" CHECK ("minimumOrderQuantity" >= 1 AND ("maximumOrderQuantity" IS NULL OR "maximumOrderQuantity" >= "minimumOrderQuantity"));
