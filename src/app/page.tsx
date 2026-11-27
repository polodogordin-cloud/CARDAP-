import { redirect } from 'next/navigation';
import { isConfigured } from '@/lib/supabase/server';
export default function Home() { redirect(isConfigured() ? '/login' : '/demo-restaurante/dashboard'); }
