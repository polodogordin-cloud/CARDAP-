-- Run ONLY against disposable local/staging Supabase after migrations.
-- psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/tenant_isolation.sql
begin;
insert into auth.users(id) values
 ('10000000-0000-0000-0000-000000000001'),
 ('10000000-0000-0000-0000-000000000002');
insert into public.establishments(id,slug,name) values
 ('20000000-0000-0000-0000-000000000001','test-a','Tenant A'),
 ('20000000-0000-0000-0000-000000000002','test-b','Tenant B');
insert into public.memberships(establishment_id,user_id,role) values
 ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','owner'),
 ('20000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','owner');
set local role authenticated;
select set_config('request.jwt.claim.sub','10000000-0000-0000-0000-000000000001',true);
do $$ declare affected integer; begin
 if (select count(*) from public.establishments) <> 1 then raise exception 'Tenant read isolation failed'; end if;
 if exists(select 1 from public.establishments where slug='test-b') then raise exception 'Tenant B leaked'; end if;
 update public.establishments set name='Forbidden' where slug='test-b';
 get diagnostics affected = row_count;
 if affected <> 0 then raise exception 'Cross-tenant update succeeded'; end if;
 update public.establishments set name='Allowed' where slug='test-a';
 get diagnostics affected = row_count;
 if affected <> 1 then raise exception 'Owner update failed'; end if;
 begin
  update public.memberships set role='manager';
  raise exception 'Membership write unexpectedly allowed';
 exception when insufficient_privilege then null;
 end;
 if public.is_platform_admin() then raise exception 'Owner escalated to platform admin'; end if;
end $$;
reset role;
update public.memberships set active=false where user_id='10000000-0000-0000-0000-000000000001';
set local role authenticated;
do $$ begin
 if exists(select 1 from public.establishments) then raise exception 'Revoked membership still has access'; end if;
end $$;
reset role;
set local role anon;
do $$ begin
 begin
  perform * from public.establishments;
  raise exception 'Anonymous table access unexpectedly allowed';
 exception when insufficient_privilege then null;
 end;
end $$;
reset role;
rollback;
