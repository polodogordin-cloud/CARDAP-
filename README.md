# CARDAPÊ — Plataforma SaaS para Alimentação

> Uma única plataforma para restaurantes, lanchonetes, pizzarias, hamburguerias, cafeterias, sorveterias, bares, food trucks e similares. O tipo de estabelecimento é **configuração**, não código duplicado.

**Status:** Fundação técnica (Etapa 1) — shell administrativo e modo demonstração funcionais; auth base e migration multi-tenant preparadas, com integração de banco ainda a validar. Funcionalidades de negócio serão entregues por etapas.

---

## Visão rápida

- **Produto:** Cardápio digital + QR por mesa + pedidos (mesa/retirada/delivery) + cozinha + caixa + gestão completa.
- **Modelo:** SaaS multi-tenant. Cada estabelecimento contrata separadamente, mas todos usam o mesmo núcleo.
- **Stack:** Next.js 15 (App Router) + TypeScript + Tailwind CSS + Supabase (Postgres + Auth; Storage e Realtime planejados) + Vercel.
- **Multi-tenancy:** Banco compartilhado, schema compartilhado, `establishment_id` em toda tabela de tenant + Row Level Security (RLS). Ver [ADR-002](docs/adr/002-multi-tenancy-rls.md).
- **Auth:** Supabase Auth + tabela `profiles` + `memberships` + RBAC por permissões. Ver [docs/AUTH_AND_PERMISSIONS.md](docs/AUTH_AND_PERMISSIONS.md).

## Como rodar

```bash
npm install
cp .env.example .env.local   # preencha com as chaves do Supabase
npm run dev                  # http://localhost:3000
```

Sem chaves do Supabase, a app sobe em **modo demo** (dados mockados) para visualização do shell. Com chaves, tenta autenticação real: aplique a migration e provisione usuário/estabelecimento/vínculo antes do acesso. Não há onboarding ou CRUD nesta etapa.

Rotas principais:
- `/login` — login do staff
- `/super-admin` — área da plataforma (Super Admin)
- `/[tenantSlug]/dashboard` — painel do estabelecimento (ex.: `/demo-restaurante/dashboard`)
- `/cardapio/[slug]` — cardápio público do cliente (QR)

## Documentação

| Documento | Conteúdo |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Arquitetura, módulos, navegação, crescimento |
| [docs/DATA_MODEL.md](docs/DATA_MODEL.md) | Entidades, relações, convenções |
| [docs/AUTH_AND_PERMISSIONS.md](docs/AUTH_AND_PERMISSIONS.md) | Perfis, permissões, guards |
| [docs/MODULES.md](docs/MODULES.md) | Mapa de módulos e dependências |
| [docs/SECURITY.md](docs/SECURITY.md) | Padrões de segurança |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Etapas futuras |
| [docs/adr/](docs/adr/) | Decisões arquiteturais (ADRs) |

## Estrutura

```
src/
  app/            # Rotas (App Router): (auth), (admin)/[tenantSlug], (platform), cardapio/[slug]
  components/     # ui/ (design system) + layout/ (shell) + shared/
  features/       # Módulos de negócio (catalog, ordering, operations, ...)
  lib/            # supabase/, auth/, tenant/, validators/, utils
  types/          # Tipos do banco + domínio
  hooks/
supabase/
  migrations/     # SQL versionado (schema + RLS)
  seed.sql
docs/
```

## Princípios

1. **Núcleo único, configuração por estabelecimento.** Nada de `if (tipo === 'pizzaria')` espalhado. Diferenças viram `establishment.settings`, módulos habilitados e permissões.
2. **Tenant em tudo.** Toda operação carrega `establishment_id` validado no servidor. Cliente nunca escolhe tenant sozinho.
3. **Segurança por padrão.** RLS + validação Zod + guards de permissão em Server Components/Actions.
4. **Modular e reutilizável.** Componentes de UI e helpers compartilhados; features isoladas por pasta.
5. **Simples para quem opera.** Telas limpas, responsivas (desktop/tablet/celular), sem complexidade desnecessária.

## Próximas etapas (após esta fundação)

1. Validar RLS em staging + CRUD de estabelecimentos + onboarding
2. Catálogo (categorias/produtos/modificadores/combos)
3. Mesas + QR + sessão do cliente
4. Pedidos + cozinha (Realtime)
5. Caixa + pagamentos
6. Clientes, equipe, permissões finas
7. Relatórios, promoções, cupons, integrações

Ver [docs/ROADMAP.md](docs/ROADMAP.md).

## Validação e banco

```bash
npm run typecheck
npm test
npm run build
npm audit
# Com Supabase CLI e Docker instalados:
supabase start
supabase db reset
# Teste de isolamento (ambiente descartável):
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/tenant_isolation.sql
```

A migration em `supabase/migrations/202611270001_foundation.sql` não foi aplicada em banco remoto por esta entrega. O teste SQL está preparado, mas depende de Postgres/Supabase. Não há credenciais padrão. Consulte os limites de produção em [SECURITY](docs/SECURITY.md). A demonstração não persiste dados.
