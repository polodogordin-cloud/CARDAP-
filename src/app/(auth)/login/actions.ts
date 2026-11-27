'use server';
import { redirect } from 'next/navigation';
import { z } from 'zod';
import { createClient, isConfigured } from '@/lib/supabase/server';
export async function login(form: FormData) {
 if (!isConfigured()) redirect('/login?error=configuration');
 const parsed=z.object({email:z.string().email().max(254),password:z.string().min(8).max(128)}).safeParse(Object.fromEntries(form));
 if(!parsed.success) redirect('/login?error=credentials');
 const db=await createClient(); const {error}=await db.auth.signInWithPassword(parsed.data);
 if(error) redirect('/login?error=credentials');
 const { data }=await db.from('memberships').select('role,establishments(slug)').eq('active',true).limit(1).single();
 const establishment=data?.establishments as unknown as {slug:string}|null;
 if(!establishment) redirect('/login?error=membership');
 const landing = data?.role === 'kitchen' ? 'cozinha' : data?.role === 'cashier' ? 'caixa' : data?.role === 'waiter' ? 'pedidos' : 'dashboard';
 redirect(`/${establishment.slug}/${landing}`);
}
export async function logout() { const db=await createClient(); await db.auth.signOut(); redirect('/login'); }
