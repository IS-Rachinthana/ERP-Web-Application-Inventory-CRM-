CREATE TYPE "AppRole" AS ENUM ('OWNER', 'ADMIN', 'MANAGER', 'SALES_REP', 'STOREKEEPER', 'ACCOUNTANT', 'TECHNICIAN');

CREATE TABLE "Profile" (
  "id" UUID NOT NULL, "email" TEXT NOT NULL, "fullName" TEXT, "role" "AppRole" NOT NULL DEFAULT 'STOREKEEPER',
  "isActive" BOOLEAN NOT NULL DEFAULT true, "branchId" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Profile_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "Profile_email_key" ON "Profile"("email");
CREATE TABLE "AuditLog" (
  "id" TEXT NOT NULL, "actorId" UUID, "action" TEXT NOT NULL, "entityType" TEXT NOT NULL, "entityId" TEXT,
  "detail" JSONB, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "AuditLog_actorId_idx" ON "AuditLog"("actorId");
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "Profile"("id") ON DELETE SET NULL ON UPDATE CASCADE;
CREATE TABLE "CompanySetting" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "currency" "Currency" NOT NULL DEFAULT 'USD', "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "CompanySetting_pkey" PRIMARY KEY ("id"));
CREATE TABLE "Branch" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "code" TEXT NOT NULL, "address" TEXT, "isActive" BOOLEAN NOT NULL DEFAULT true, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT "Branch_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "Branch_code_key" ON "Branch"("code");
CREATE TABLE "TaxRate" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "rate" DECIMAL(5,2) NOT NULL, "isActive" BOOLEAN NOT NULL DEFAULT true, CONSTRAINT "TaxRate_pkey" PRIMARY KEY ("id"));
CREATE TABLE "Unit" ("id" TEXT NOT NULL, "name" TEXT NOT NULL, "symbol" TEXT NOT NULL, CONSTRAINT "Unit_pkey" PRIMARY KEY ("id"));
CREATE UNIQUE INDEX "Unit_symbol_key" ON "Unit"("symbol");

CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public."Profile" ("id", "email", "fullName", "role") VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data ->> 'full_name', CASE WHEN NOT EXISTS (SELECT 1 FROM public."Profile") THEN 'OWNER'::public."AppRole" ELSE 'STOREKEEPER'::public."AppRole" END) ON CONFLICT ("id") DO NOTHING;
  RETURN NEW;
END;
$$;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

ALTER TABLE "Profile" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "AuditLog" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "CompanySetting" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Branch" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TaxRate" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Unit" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profile_select_self" ON "Profile" FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "audit_select_owner_admin" ON "AuditLog" FOR SELECT TO authenticated USING ((SELECT role FROM "Profile" WHERE id = auth.uid()) IN ('OWNER','ADMIN'));
CREATE POLICY "settings_read_authenticated" ON "CompanySetting" FOR SELECT TO authenticated USING (true);
CREATE POLICY "branches_read_authenticated" ON "Branch" FOR SELECT TO authenticated USING (true);
CREATE POLICY "tax_read_authenticated" ON "TaxRate" FOR SELECT TO authenticated USING (true);
CREATE POLICY "units_read_authenticated" ON "Unit" FOR SELECT TO authenticated USING (true);
