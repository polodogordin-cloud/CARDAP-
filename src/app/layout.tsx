import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'CARDAPÊ • Gestão descomplicada', description: 'Uma plataforma. Todas as possibilidades do seu negócio.' };
export default function RootLayout({ children }: { children: React.ReactNode }) { return <html lang="pt-BR"><body>{children}</body></html>; }
