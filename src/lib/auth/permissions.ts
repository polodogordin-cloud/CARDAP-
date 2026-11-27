export const roles = ['owner', 'manager', 'waiter', 'kitchen', 'cashier'] as const;
export type Role = typeof roles[number];
export const permissions = ['dashboard:read', 'catalog:write', 'orders:write', 'kitchen:write', 'tables:write', 'cash:write', 'customers:read', 'staff:write', 'settings:write'] as const;
export type Permission = typeof permissions[number];
const grants: Record<Role, readonly Permission[]> = {
  owner: permissions,
  manager: ['dashboard:read','catalog:write','orders:write','kitchen:write','tables:write','cash:write','customers:read'],
  waiter: ['orders:write','tables:write'],
  kitchen: ['kitchen:write'],
  cashier: ['cash:write','orders:write'],
};
export function can(role: string, permission: Permission): boolean {
  return Object.prototype.hasOwnProperty.call(grants, role) && grants[role as Role].includes(permission);
}
export const roleLabels: Record<Role, string> = { owner: 'Proprietário', manager: 'Gerente', waiter: 'Garçom / Atendente', kitchen: 'Cozinha', cashier: 'Caixa' };
