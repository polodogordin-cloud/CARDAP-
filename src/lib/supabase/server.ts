import 'server-only';
import { createServerClient, type CookieOptions } from '@supabase/ssr';
import { cookies } from 'next/headers';
export const isConfigured = () => Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
export async function createClient() {
  if (!isConfigured()) throw new Error('Supabase não configurado.');
  const store = await cookies();
  return createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!, {
    cookies: { getAll: () => store.getAll(), setAll(values: {name:string;value:string;options:CookieOptions}[]) { try { values.forEach(({ name, value, options }) => store.set(name, value, options)); } catch { /* Server Component: refresh handled by middleware */ } } },
  });
}
