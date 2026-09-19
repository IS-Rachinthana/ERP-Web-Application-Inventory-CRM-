import { prisma } from "@/lib/prisma";

async function getMetrics() {
  try {
    const [products, customers, sales, lowStock] = await Promise.all([
      prisma.product.count(),
      prisma.customer.count(),
      prisma.sale.count({ where: { status: "COMPLETED" } }),
      prisma.product.count({ where: { quantity: { lte: 5 } } })
    ]);
    return { products, customers, sales, lowStock, connected: true };
  } catch {
    return { products: 0, customers: 0, sales: 0, lowStock: 0, connected: false };
  }
}

export default async function Home() {
  const metrics = await getMetrics();
  const cards = [
    ["Products", metrics.products, "Items in catalog"],
    ["Customers", metrics.customers, "CRM contacts"],
    ["Completed sales", metrics.sales, "Recorded orders"],
    ["Low stock", metrics.lowStock, "At or below 5 units"]
  ];

  return (
    <main>
      <nav><strong>Stockwise</strong><span>Inventory & CRM</span><span className={metrics.connected ? "status good" : "status"}>{metrics.connected ? "Database connected" : "Database setup pending"}</span></nav>
      <section className="hero">
        <p className="eyebrow">OPERATIONS OVERVIEW</p>
        <h1>Keep stock and customer relationships in one place.</h1>
        <p className="intro">Your starter ERP is deployed and ready for data. Tables are applied automatically during deployment.</p>
      </section>
      <section className="cards">
        {cards.map(([label, value, detail]) => <article className="card" key={String(label)}><p>{label}</p><strong>{value}</strong><small>{detail}</small></article>)}
      </section>
      <section className="panel">
        <div><p className="eyebrow">NEXT STEP</p><h2>Add your first products and customers</h2><p>Tables included: products, customers, sales, and sale items.</p></div>
        <div className="badge">Supabase PostgreSQL</div>
      </section>
    </main>
  );
}
