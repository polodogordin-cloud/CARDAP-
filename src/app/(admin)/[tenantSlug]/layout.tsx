import { requireTenant } from '@/lib/tenant/context';
import { AdminShell } from '@/components/layout/admin-shell';
export default async function Layout({ children, params }: { children: React.ReactNode; params: Promise<{tenantSlug:string}> }) { const {tenantSlug} = await params; const tenant = await requireTenant(tenantSlug); return <AdminShell tenant={tenant}>{children}</AdminShell>; }
