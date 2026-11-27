import { test } from 'node:test';
import assert from 'node:assert/strict';
import { can, permissions } from '../src/lib/auth/permissions';
test('owner has all tenant permissions', () => permissions.forEach(p => assert.equal(can('owner', p), true)));
test('kitchen cannot access cash or settings', () => { assert.equal(can('kitchen', 'cash:write'), false); assert.equal(can('kitchen', 'settings:write'), false); assert.equal(can('kitchen', 'kitchen:write'), true); });
test('unknown roles fail closed, including platform and customer', () => ['super_admin','customer','invalid','__proto__'].forEach(r => assert.equal(can(r,'settings:write'), false)));
test('manager cannot administer staff or settings', () => { assert.equal(can('manager','staff:write'),false); assert.equal(can('manager','settings:write'),false); });
test('waiter and cashier have focused access', () => { assert.equal(can('waiter','tables:write'),true); assert.equal(can('waiter','cash:write'),false); assert.equal(can('cashier','cash:write'),true); assert.equal(can('cashier','catalog:write'),false); });
