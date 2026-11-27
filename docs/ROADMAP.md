# Desenvolvimento incremental

1. **Fundação (esta entrega):** arquitetura, ADRs, shell responsivo, contexto tenant, auth base, RBAC, migration com RLS, testes unitários. Nenhum CRUD operacional.
2. **Onboarding:** provisionamento transacional empresa + proprietário, seletor de empresas, convites, recuperação/MFA, dados e identidade visual, horários e canais. Critério: sessões A/B não acessam dados cruzados; teste de RLS em CI.
3. **Catálogo:** categorias/produtos/adicionais/combos, imagens e publicação; validação de preços e isolamento.
4. **Cliente e mesas:** QR revogável, sessão por mesa, catálogo público explicitamente publicado, carrinho e pedidos mesa/retirada; controles antiabuso.
5. **Operação:** ciclo de pedido, cozinha, chamar garçom/conta, painel de atendimento e Realtime autorizado.
6. **Financeiro:** caixa, divisão de conta, pagamentos e delivery; fechamento conciliado, idempotência e auditoria.
7. **Gestão ampliada:** clientes, estoque, permissões detalhadas, promoções e cupons.
8. **SaaS e escala:** cobrança recorrente, limites de planos, relatórios, notificações, integrações e observabilidade completa.

Cada etapa exige migração revisada, testes negativos de tenant/role, estados vazios/erro/loading, acessibilidade e verificação móvel. Próxima etapa depende de novo comando; não ampliar automaticamente o escopo.
