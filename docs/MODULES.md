# Módulos de um único produto

| Módulo | Responsabilidade | Dependências |
|---|---|---|
| Identity / tenancy | Auth, vínculo e contexto | Supabase Auth |
| Establishments | Empresa, marca, canais e horários | Identity |
| Catalog | Produtos, categorias, complementos, combos | Establishments |
| Ordering | Carrinho, pedido, histórico, preços | Catalog, Establishments |
| Operations | Mesas, QR, atendimento, cozinha | Ordering |
| Customers | Dados do cliente e consentimento | Establishments |
| Staff | Equipe e permissões | Identity |
| Finance | Caixa, pagamentos, divisão, estornos | Ordering |
| Marketing | Promoções e cupons | Catalog, Ordering |
| Analytics | Indicadores e relatórios | Eventos de módulos operacionais |
| Settings | Preferências e módulos | Establishments |
| Platform | SaaS, planos e gestão global | Identity |

Habilitação de módulo não substitui permissão. Operação futura exige ambas e deve verificar os limites comerciais no servidor. Nenhuma bifurcação por segmento: tamanhos de pizza, pontos da carne ou sabores são configurações de modificadores, sem duplicar pedidos ou catálogo.

Fronteiras: nenhum módulo escreve em tabelas de outro diretamente; usa serviço/caso de uso. Eventos assíncronos só quando necessários; transações locais para invariantes fortes.
