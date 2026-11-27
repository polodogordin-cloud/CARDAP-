# ADR-002 — Shared schema + tenant ID + RLS
Status: aceito. Data: 2026-11-27.

Decisão: um banco/schema compartilhado; `establishment_id` obrigatório nas entidades tenant. RLS checa usuário e vínculo ativo. Slug só resolve contexto, não concede acesso.
Motivo: milhares de tenants com migrations únicas e custo operacional previsível. Schema/banco por cliente complicaria pooling, provisionamento e upgrades prematuramente.
Consequências: exige políticas e índices em cada tabela, FKs compostas e testes negativos obrigatórios. Risco de noisy neighbor mitigado com limites, índices e observabilidade; tenants de carga excepcional poderão migrar para shards no futuro. Nunca filtrar apenas no frontend.
