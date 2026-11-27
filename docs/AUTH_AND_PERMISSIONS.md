# Autenticação e autorização

Supabase Auth gerencia senha, sessão e verificação de identidade. Middleware renova cookies; servidor usa `getUser()`, não confia apenas no conteúdo local da sessão. Login validado com Zod, erros genéricos. Depois do login a função direciona o usuário ao primeiro vínculo ativo. Seletor multiestabelecimento será entregue no onboarding.

| Perfil | Acesso inicial |
|---|---|
| Super Admin | Área da plataforma; não herda acesso de proprietário nem operações de caixa |
| Proprietário | Todos os módulos do próprio estabelecimento |
| Gerente | Dashboard, catálogo, pedidos, cozinha, mesas, caixa, clientes; não equipe/configurações |
| Garçom/Atendente | Pedidos e mesas |
| Cozinha | Fila de cozinha |
| Caixa | Caixa e pedidos |
| Cliente | Experiência pública; nenhum acesso administrativo |

Matriz executável: `src/lib/auth/permissions.ts`. Permissões representam capacidades reservadas para os módulos futuros, não operações já disponíveis. Cliente pode ser anônimo e futuramente autenticado; não é uma membership de staff. Papel global Super Admin é separado dos papéis tenant.

## Camadas
1. Ocultar navegação sem permissão (UX).
2. Guards em cada página/ação com usuário e membership ativa (segurança da aplicação).
3. RLS e privilégios de coluna no Postgres (defesa final).

Role, tenant ID ou flag admin enviados pelo cliente nunca concedem acesso. `requireTenant` valida slug → UUID visível via RLS → membership do usuário. Outra empresa retorna 404. Desativação do vínculo é consultada em cada requisição, sem papéis congelados no JWT.

## Bootstrap e limites atuais
A migration não cria senhas, administradores ou empresas. Em ambiente local crie usuários via Supabase Auth; um operador confiável cadastra estabelecimento e owner em transação usando SQL administrativo. Nunca pelo navegador nem metadata controlável pelo usuário. Convites, recuperação de senha, MFA, onboarding e gestão de vínculos são próximas etapas. Não há API pública de criação de tenant.

Sem variáveis do Supabase, apenas `demo-restaurante` é aceito e nenhum banco é usado. Não há fallback demo quando um Supabase configurado falha. Demo não deve ser interpretado como autenticação validada em produção.
