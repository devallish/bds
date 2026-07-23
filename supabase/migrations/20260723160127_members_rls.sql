-- Region-based, three-tier access control per CLAUDE.md: member sees only their own
-- row, regional coordinator sees their region, national admin sees everything.
--
-- SECURITY DEFINER + explicit search_path avoids two problems: infinite recursion
-- (a policy on `members` querying `members` directly would recurse into itself),
-- and search_path hijacking (an unqualified function name resolving to a
-- caller-controlled schema).

create or replace function public.get_my_role()
returns member_role
language sql
security definer
set search_path = public
stable
as $$
  select role from members where user_id = auth.uid()
$$;

create or replace function public.get_my_region()
returns text
language sql
security definer
set search_path = public
stable
as $$
  select region from members where user_id = auth.uid()
$$;

-- Generalised form of get_my_region(), for policies on other tables (person,
-- address, membership_period) that need to check an arbitrary row's owning
-- member's region rather than the caller's own.
create or replace function public.region_of(target_user_id uuid)
returns text
language sql
security definer
set search_path = public
stable
as $$
  select region from members where user_id = target_user_id
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

create trigger members_set_edited_metadata
  before update on members
  for each row
  execute function public.set_edited_metadata();

alter table person enable row level security;
grant select, insert, update on person to authenticated;

create policy "person_select_own" on person
  for select
  using (user_id = auth.uid());

create policy "person_select_region_coordinator" on person
  for select
  using (get_my_role() = 'regional_coordinator' and region_of(user_id) = get_my_region());

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

alter table members enable row level security;

-- RLS restricts which rows are visible, but Postgres still requires a
-- table-level grant before any policy is evaluated at all.
grant select, insert, update on members to authenticated;

create policy "members_select_own" on members
  for select
  using (user_id = auth.uid());

create policy "members_select_region_coordinator" on members
  for select
  using (get_my_role() = 'regional_coordinator' and region = get_my_region());

create policy "members_select_all_national_admin" on members
  for select
  using (get_my_role() = 'national_admin');

create policy "members_update_own" on members
  for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "members_update_all_national_admin" on members
  for update
  using (get_my_role() = 'national_admin')
  with check (get_my_role() = 'national_admin');

-- Real signups will insert via a security-definer trigger on auth.users (future
-- work, part of the AuthRepository adapter) which bypasses RLS as the function
-- owner. This policy only covers admin-driven inserts (e.g. adding a test member).
create policy "members_insert_national_admin" on members
  for insert
  with check (get_my_role() = 'national_admin');
