import 'server-only';
import { notFound, redirect } from 'next/navigation';
import { createClient, isConfigured } from '@/lib/supabase/server';
import { roles, type Role } from '@/lib/auth/permissions';
export type TenantContext = { id: string; slug: string; name: string; role: Role; demo: boolean };
export async function requireTenant(slug: string): Promise<TenantContext> {
  if (!isConfigured()) {
    if (slug !== 'demo-restaurante') notFound();
    return { id: 'demo', slug, name: 'Seu estabelecimento', role: 'owner', demo: true };
  }
  const db = await createClient();
  const { data: { user } } = await db.auth.getUser();
  if (!user) redirect('/login');
  const { data: tenant } = await db.from('establishments').select('id,slug,name').eq('slug', slug).single();
  if (!tenant) notFound();
  const { data: member } = await db.from('memberships').select('role').eq('establishment_id', tenant.id).eq('user_id', user.id).eq('active', true).single();
  if (!member || !roles.includes(member.role)) notFound();
  return { ...tenant, role: member.role, demo: false };
}
