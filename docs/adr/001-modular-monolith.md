# ADR-001 — Monólito modular web
Status: aceito. Data: 2026-11-27.

Contexto: produto único, muitas capacidades futuras e nenhuma carga operacional conhecida.
Decisão: Next.js/TypeScript + Supabase Postgres/Auth, um deploy com módulos por domínio.
Alternativa: microsserviços desde o início. Rejeitada pelo custo de coordenação, consistência e infraestrutura sem benefício mensurável.
Consequências: transações simples e velocidade com fronteiras explícitas; extração futura por métricas, não por antecipação. Supabase concentra dependências operacionais, mitigadas por SQL versionado e contratos de domínio.
