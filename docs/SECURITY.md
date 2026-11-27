# Segurança por padrão

## Entregue
- RLS ativa nas seis tabelas; anônimo sem acesso a dados de gestão.
- Membership ativa validada no banco e aplicação. Escrita em vínculos e módulos negada a clientes.
- Funções SECURITY DEFINER com search_path vazio e grants explícitos; não aceitam user ID arbitrário.
- Service role não utilizada no app. Credenciais apenas em env; `.env.local` ignorado.
- Sessões em cookies SSR, guards servidor, Zod no login, React escapa conteúdo.
- Headers nosniff/referrer/permissions. Nenhuma permissão ampla para imagens remotas.

## Antes de produção
- Aplicar migrations em staging; executar `supabase/tests/tenant_isolation.sql` com psql ou SQL editor em ambiente descartável. RLS **não foi executada neste sandbox**.
- Testar tenant A/B com sessões reais, membership revogada, papéis e Server Actions. Testes unitários atuais cobrem somente RBAC, não substituem integração.
- Configurar SMTP, URLs autorizadas e rate limits do Supabase Auth; proteção antiabuso e limitação distribuída das futuras APIs. Não há rate limiter distribuído nesta etapa.
- MFA obrigatório para plataforma/proprietários antes de dados reais; recuperação e convites auditados.
- HTTPS, cookies seguros, CSP ajustada ao deploy; se embutir no preview, não bloquear iframe indiscriminadamente. HSTS no domínio de produção.
- Storage privado por padrão; caminho com tenant, policies de bucket, limites de tamanho, MIME e assinatura; uploads ainda não implementados.
- Auditoria transacional nas futuras mutações; logs sem senha, token, endereço completo ou dados de cartão. Nunca confiar em totais do browser.
- Backups/PITR conforme plano, restauração testada, retenção e resposta a incidentes. LGPD: finalidade, consentimento quando necessário, exportação e exclusão.
- Pagamentos somente via provedor; webhook com assinatura, replay protection e idempotência. Nunca armazenar cartão.
- CI: tipos, testes, build e auditoria de dependências. Nenhuma chave de service role em `NEXT_PUBLIC_*`.

## Acesso da plataforma
Super Admin pode ler identidade dos estabelecimentos para futura gestão comercial. Não recebe acesso implícito aos pedidos/dados sensíveis. Suporte com impersonação exigirá autorização, duração limitada e auditoria — não implementado.
