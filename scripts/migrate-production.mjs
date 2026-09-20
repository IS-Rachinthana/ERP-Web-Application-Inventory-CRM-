import { execFileSync } from "node:child_process";

if (process.env.VERCEL_ENV === "production") {
  execFileSync(process.platform === "win32" ? "npx.cmd" : "npx", ["prisma", "migrate", "deploy"], { stdio: "inherit" });
} else {
  console.log("Skipping database migration outside the Vercel Production environment.");
}
