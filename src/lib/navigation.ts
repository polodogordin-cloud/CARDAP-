import type { Permission } from './auth/permissions';
export const navigation: { key: string; label: string; group: string; permission: Permission }[] = [
  {key:'dashboard',label:'Visão geral',group:'PRINCIPAL',permission:'dashboard:read'},
  {key:'pedidos',label:'Pedidos',group:'OPERAÇÃO',permission:'orders:write'},
  {key:'mesas',label:'Mesas e atendimento',group:'OPERAÇÃO',permission:'tables:write'},
  {key:'cozinha',label:'Cozinha',group:'OPERAÇÃO',permission:'kitchen:write'},
  {key:'cardapio',label:'Meu cardápio',group:'GESTÃO',permission:'catalog:write'},
  {key:'clientes',label:'Clientes',group:'GESTÃO',permission:'customers:read'},
  {key:'equipe',label:'Equipe e acessos',group:'GESTÃO',permission:'staff:write'},
  {key:'caixa',label:'Caixa',group:'GESTÃO',permission:'cash:write'},
  {key:'configuracoes',label:'Configurações',group:'ESTABELECIMENTO',permission:'settings:write'},
];
