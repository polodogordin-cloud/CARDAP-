-- CARDAPÊ foundation. Apply using Supabase migrations; never run as browser SQL.
begin;
create type public.staff_role as enum ('owner','manager','waiter','kitchen','cashier');
create type public.business_type as enum ('restaurant','snack_bar','pizzeria','burger_shop','cafe','ice_cream','bar','food_truck','other');
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now()
);
create table public.platform_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table public.establishments (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name text not null check (length(name) between 1 and 120),
  business_type public.business_type not null default 'restaurant',
  logo_path text,
  brand_color text not null default '#ea580c',
  address jsonb not null default '{}',
  contacts jsonb not null default '{}',
  opening_hours jsonb not null default '{}',
  timezone text not null default 'America/Fortaleza',
  currency text not null default 'BRL' check (currency = 'BRL'),
  settings jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.memberships (
  establishment_id uuid not null references public.establishments(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.staff_role not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (establishment_id,user_id)
);
create index memberships_user_idx on public.memberships(user_id,establishment_id) where active;
create table public.establishment_modules (
  establishment_id uuid not null references public.establishments(id) on delete cascade,
  module_key text not null,
  enabled boolean not null default false,
  configuration jsonb not null default '{}',
  primary key (establishment_id,module_key)
);
create table public.audit_events (
  id uuid primary key default gen_random_uuid(),
  establishment_id uuid not null references public.establishments(id),
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  resource_type text not null,
  resource_id uuid,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create index audit_tenant_date_idx on public.audit_events(establishment_id,created_at desc);
-- Security definer prevents recursive membership policies. No externally provided user id.
create function public.tenant_role(tenant_id uuid) returns public.staff_role
language sql stable security definer set search_path = '' as $$
 select role from public.memberships where establishment_id = tenant_id and user_id = (select auth.uid()) and active;
$$;
create function public.is_platform_admin() returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.platform_admins where user_id = (select auth.uid()));
$$;
revoke all on function public.tenant_role(uuid) from public;
revoke all on function public.is_platform_admin() from public;
grant execute on function public.tenant_role(uuid), public.is_platform_admin() to authenticated;

alter table public.profiles enable row level security;
alter table public.platform_admins enable row level security;
alter table public.establishments enable row level security;
alter table public.memberships enable row level security;
alter table public.establishment_modules enable row level security;
alter table public.audit_events enable row level security;

create policy profile_read on public.profiles for select to authenticated using (id = (select auth.uid()));
create policy profile_update on public.profiles for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy platform_self_read on public.platform_admins for select to authenticated using (user_id = (select auth.uid()));
create policy tenant_read on public.establishments for select to authenticated using (public.tenant_role(id) is not null or public.is_platform_admin());
create policy tenant_update on public.establishments for update to authenticated using (public.tenant_role(id) = 'owner') with check (public.tenant_role(id) = 'owner');
create policy membership_read on public.memberships for select to authenticated using (user_id = (select auth.uid()) or public.tenant_role(establishment_id) = 'owner');
-- Membership writes only through trusted onboarding/invite transactions, never direct client writes.
create policy module_read on public.establishment_modules for select to authenticated using (public.tenant_role(establishment_id) is not null);
-- Entitlements are platform controlled; no tenant write policy.
create policy audit_read on public.audit_events for select to authenticated using (public.tenant_role(establishment_id) = 'owner');
-- Audit writes only through trusted server transactions/triggers; never direct client inserts.
revoke all on public.profiles, public.platform_admins, public.establishments, public.memberships, public.establishment_modules, public.audit_events from anon, authenticated;
grant select, update(display_name) on public.profiles to authenticated;
grant select on public.platform_admins, public.memberships, public.establishment_modules, public.audit_events to authenticated;
grant select, update(name,business_type,logo_path,brand_color,address,contacts,opening_hours,timezone,settings) on public.establishments to authenticated;

create function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin insert into public.profiles(id) values (new.id); return new; end;
$$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
create function public.touch_updated_at() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end;
$$;
create trigger establishment_updated before update on public.establishments for each row execute function public.touch_updated_at();
revoke all on function public.handle_new_user(), public.touch_updated_at() from public;
commit;
