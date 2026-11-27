# Modelo de dados

## Implementado na migration
- `profiles(id → auth.users)`: nome de exibição; não armazena senha ou papel global de staff.
- `platform_admins(user_id → auth.users)`: privilégio global concedido somente por operação administrativa confiável.
- `establishments(id, slug, name, business_type, logo_path, brand_color, address, contacts, opening_hours, timezone, currency, settings)`: identidade e contexto.
- `memberships(establishment_id, user_id, role, active)`: chave composta, uma função por usuário/estabelecimento.
- `establishment_modules(establishment_id, module_key, enabled, configuration)`: habilitação da plataforma. Não representa, por si só, cobrança ou assinatura.
- `audit_events(id, establishment_id, actor_id, action, resource_type, resource_id, metadata, created_at)`: contrato inicial append-only para clientes. Ainda não há produtores de eventos de negócio.

Relações: usuário N:N estabelecimento via membership; estabelecimento 1:N módulos e eventos. Usuário não pertence exclusivamente a uma empresa.

## Próximas entidades — desenho, não tabelas criadas
Todas abaixo levam `establishment_id not null` e RLS:

| Módulo | Entidades e relações |
|---|---|
| Catálogo | categories → products; modifier_groups → modifier_options; product_modifier_groups; combos → combo_items |
| Atendimento | tables → table_sessions; service_requests (garçom/conta); QR tokens revogáveis |
| Pedidos | orders → order_items → order_item_modifiers; order_status_events; canal table/pickup/delivery |
| Clientes | customers (auth_user_id opcional), customer_addresses; consentimentos |
| Caixa | cash_sessions → cash_movements; payments; refunds; bill_allocations (divisão da conta) |
| Estoque | inventory_items, recipes, stock_movements; saldo derivado/transacional |
| Promoções | promotions, coupons, coupon_redemptions |
| SaaS | plans, subscriptions, billing_events; entitlements por estabelecimento |
| Integrações | integration_accounts, webhook_events, outbox_events, notifications |

## Convenções obrigatórias
- UUID como identidade; datas `timestamptz` em UTC; apresentação no timezone do estabelecimento.
- Valores monetários em centavos inteiros (`bigint`) e moeda explícita. Nunca ponto flutuante.
- Itens de pedido guardam snapshot de nome, preço e adicionais; mudanças do catálogo não alteram histórico.
- Relações entre tabelas tenant usam `unique(establishment_id,id)` no pai e FK composta `(establishment_id,parent_id)` no filho. Uma FK apenas em UUID não impede referência cruzada entre empresas.
- Índices iniciando por `establishment_id` nos filtros frequentes. Paginar listas e histórico.
- Status de pedidos com transições validadas por caso de uso e concorrência otimista. Pagamentos com idempotency key única por tenant/provedor.
- JSONB apenas para configurações pequenas/variáveis e snapshots; itens, dinheiro e relações consultáveis normalizados.
- PII mínima e retenção documentada por finalidade; exclusão de empresa exige processo, não delete indiscriminado de dados fiscais.
- Migrations incrementais; expand/contract em mudanças incompatíveis. Nunca sincronização destrutiva automática em produção.
