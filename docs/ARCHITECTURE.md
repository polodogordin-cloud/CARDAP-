# Arquitetura do CARDAPÊ

## Análise do produto
Um SaaS B2B com experiência pública B2C. O estabelecimento é o limite de isolamento e contratação. Restaurante, pizzaria, sorveteria e demais segmentos compartilham entidades e fluxos; diferenças são capacidades configuráveis, nunca aplicações separadas. Uma pessoa pode trabalhar em mais de um estabelecimento, com função diferente em cada um.

## Arquitetura recomendada
**Monólito modular**: Next.js App Router/TypeScript para web e camada de aplicação; Postgres/Supabase para persistência, Auth, Storage e futuro Realtime. Deploy stateless compatível com Vercel. Um deploy, uma base de código e um schema versionado. Não começar com microsserviços: prejudicariam transações e operação sem demanda comprovada.

Fluxo privado: navegador → rota/Server Action → usuário verificado via `getUser()` → `requireTenant(slug)` → permissão → consulta com `establishment_id` → RLS. Repetir o guard nas ações; layouts e menu não são barreiras suficientes. Componentes de apresentação não consultam banco diretamente.

As únicas entidades persistidas nesta etapa são identidade, estabelecimentos, vínculos, módulos e auditoria. Pedidos e catálogo estão **modelados na documentação**, não implementados.

## Navegação
- `/login`: equipe; sessão por cookie. Sem cadastro público de proprietários nesta fase.
- `/[tenantSlug]/dashboard`: gestão contextualizada. Slug é endereço, UUID é autoridade interna.
- `/[tenantSlug]/[module]`: menu filtrado por permissão e guard servidor.
- `/cardapio/[slug]`: experiência pública, isolada do shell administrativo; hoje apenas demonstração.
- `/super-admin`: controle da plataforma, sem equivaler a proprietário.

Sidebar fixa no desktop e menu móvel no celular. Cozinha/caixa poderão ganhar layouts operacionais focados; cliente verá catálogo → carrinho → confirmação com o mínimo de passos. Sem gráficos ou vendas fictícios na fundação.

## Componentes reutilizáveis
`AdminShell`, `PageHeading`, `Card`, `Badge`, configuração central de navegação e matriz de permissões. Adicionar formulários, tabelas paginadas, estados vazios, confirmação, filtros e notificações somente conforme a primeira necessidade real. Server Components por padrão, Client Components somente para interação.

## Crescimento
1. Índices com tenant primeiro; paginação por cursor; evitar carregar todo o histórico.
2. Pool de conexões; serviços stateless; nenhuma sessão em memória local.
3. Cache sempre chaveado por tenant/permissão; nunca cache global de dados privados.
4. Outbox transacional + workers para notificações/webhooks; retries e idempotência.
5. Realtime com canais privados e autorização; não publicar dados operacionais indiscriminadamente.
6. Separar workloads de relatórios; particionar histórico/retencão conforme métricas reais.
7. Extrair serviços somente quando volume/independência justificar, mantendo contratos de módulo.
8. Observabilidade: request ID, tenant ID, latência, erros e trilha de auditoria sem PII desnecessária.

## Estrutura de features
Cada módulo evolui com `schemas.ts`, `service.ts`, `repository.ts`, `actions.ts`, `components/` e testes conforme necessário. Actions validam input e autorização; services executam casos de uso; repositories sempre recebem contexto validado e filtram UUID do tenant. Não criar abstrações vazias para todos os casos futuros.
