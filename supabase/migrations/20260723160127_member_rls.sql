-- Region-based, three-tier access control per CLAUDE.md: a member sees only their
-- own row, regional coordinator sees their region, national admin sees everything.
--
-- SECURITY DEFINER + explicit search_path avoids two problems: infinite recursion
-- (a policy on `member` querying `member` directly would recurse into itself),
-- and search_path hijacking (an unqualified function name resolving to a
-- caller-controlled schema).

create or replace function public.get_my_role()
returns member_role
language sql
security definer
set search_path = public
stable
as $$
  select role from member where id = auth.uid()
$$;

create or replace function public.get_my_region_id()
returns integer
language sql
security definer
set search_path = public
stable
as $$
  select region_id from member where id = auth.uid()
$$;

-- Generalised form of get_my_region_id(), for policies on other tables (person,
-- address, membership_period) that need to check an arbitrary row's owning
-- member's region rather than the caller's own.
create or replace function public.region_of(target_id uuid)
returns integer
language sql
security definer
set search_path = public
stable
as $$
  select region_id from member where id = target_id
$$;

-- Standing convention: every member-authored table auto-populates edited_at/
-- edited_by on update. Reusable across tables; attached per-table below.
create or replace function public.set_edited_metadata()
returns trigger
language plpgsql
as $$
begin
  new.edited_at := now();
  new.edited_by := auth.uid();
  return new;
end;
$$;

create trigger person_set_edited_metadata
  before update on person
  for each row
  execute function public.set_edited_metadata();

create trigger member_set_edited_metadata
  before update on member
  for each row
  execute function public.set_edited_metadata();

alter table person enable row level security;
grant select, insert, update on person to authenticated;

create policy "person_select_own" on person
  for select
  using (user_id = auth.uid());

create policy "person_select_region_coordinator" on person
  for select
  using (get_my_role() = 'regional_coordinator' and region_of(user_id) = get_my_region_id());

create policy "person_select_all_national_admin" on person
  for select
  using (get_my_role() = 'national_admin');

create policy "person_update_own" on person
  for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "person_update_all_national_admin" on person
  for update
  using (get_my_role() = 'national_admin')
  with check (get_my_role() = 'national_admin');

create policy "person_insert_national_admin" on person
  for insert
  with check (get_my_role() = 'national_admin');

alter table member enable row level security;

-- RLS restricts which rows are visible, but Postgres still requires a
-- table-level grant before any policy is evaluated at all.
grant select, insert, update on member to authenticated;

create policy "member_select_own" on member
  for select
  using (id = auth.uid());

create policy "member_select_region_coordinator" on member
  for select
  using (get_my_role() = 'regional_coordinator' and region_id = get_my_region_id());

create policy "member_select_all_national_admin" on member
  for select
  using (get_my_role() = 'national_admin');

create policy "member_update_own" on member
  for update
  using (id = auth.uid())
  with check (id = auth.uid());

create policy "member_update_all_national_admin" on member
  for update
  using (get_my_role() = 'national_admin')
  with check (get_my_role() = 'national_admin');

-- Real signups will insert via a security-definer trigger on auth.users (future
-- work, part of the AuthRepository adapter) which bypasses RLS as the function
-- owner. This policy only covers admin-driven inserts (e.g. adding a test member).
create policy "member_insert_national_admin" on member
  for insert
  with check (get_my_role() = 'national_admin');

-- region is static reference data like address_type/membership_level: readable
-- by any authenticated user, not writable outside a migration for now.
alter table region enable row level security;
grant select on region to authenticated;

create policy "region_select_all" on region
  for select
  using (true);
