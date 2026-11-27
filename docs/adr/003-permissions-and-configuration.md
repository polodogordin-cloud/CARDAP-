# ADR-003 — RBAC por vínculo e produto configurável
Status: aceito. Data: 2026-11-27.

Decisão: papel staff reside em memberships, separado de identidade e Super Admin. Cliente não recebe membership. Negar por padrão. Configuração de segmento/canais e habilitação de módulos, nunca sistemas por tipo de negócio.
Motivo: um usuário pode exercer funções diferentes em empresas diferentes; conta global não pode vazar privilégios. JWT pode ficar defasado após revogação, então autoridade fica no banco.
Consequências: consultas de vínculo por requisição; futura customização de funções poderá adicionar role_permissions sem refazer rotas. Menu e servidor usam matriz comum; SQL da nova operação deve refletir a mesma regra e ter teste de integração.
