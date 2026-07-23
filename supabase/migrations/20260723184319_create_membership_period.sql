-- membership_level: lookup table for tiers of membership (individual, family,
-- etc.) — same rationale as address_type: reference data BDS staff may extend
-- without a deploy. Values here are placeholders pending BDS's actual tier
-- list, same caveat as members.region.
create table membership_level (
  code text primary key,
  label text not null
);

comment on table membership_level is 'Lookup table for membership tiers — placeholder values pending BDS''s actual tier list.';

insert into membership_level (code, label) values
  ('individual', 'Individual'),
  ('family', 'Family'),
  ('junior', 'Junior'),
  ('life', 'Life');

-- membership_period: the membership_level a member held over a bounded date
-- range. effective_from/effective_to are both required (typically a year).
-- The exclusion constraint stops a member holding two overlapping periods —
-- Postgres's native tool for this is a range type + GiST exclusion constraint
-- rather than an application-level check.
create extension if not exists btree_gist;

create table membership_period (
  id uuid primary key default gen_random_uuid(),
  member_user_id uuid not null references members (user_id) on delete cascade,
  membership_level_id text not null references membership_level (code),
  effective_from date not null,
  effective_to date not null,
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) default auth.uid(),
  edited_at timestamptz,
  edited_by uuid references auth.users (id) on delete set null,
  constraint membership_period_valid_range check (effective_to >= effective_from),
  exclude using gist (
    member_user_id with =,
    daterange(effective_from, effective_to, '[]') with &&
  )
);

comment on table membership_period is 'One row per period a member held a given membership_level. effective_from/effective_to are both required; overlapping periods for the same member are rejected by the exclusion constraint.';

create trigger membership_period_set_edited_metadata
  before update on membership_period
  for each row
  execute function public.set_edited_metadata();

alter table membership_period enable row level security;
grant select, insert, update on membership_period to authenticated;

create policy "membership_period_select_own" on membership_period
  for select
  using (member_user_id = auth.uid());

create policy "membership_period_select_region_coordinator" on membership_period
  for select
  using (get_my_role() = 'regional_coordinator' and region_of(member_user_id) = get_my_region());

create policy "membership_period_select_all_national_admin" on membership_period
  for select
  using (get_my_role() = 'national_admin');

-- Membership level/period changes are treated as staff-administered, not
-- self-service, unlike members/person/address where a member can edit their
-- own row — so there is no "update own" policy here, only national admin.
create policy "membership_period_update_all_national_admin" on membership_period
  for update
  using (get_my_role() = 'national_admin')
  with check (get_my_role() = 'national_admin');

create policy "membership_period_insert_national_admin" on membership_period
  for insert
  with check (get_my_role() = 'national_admin');

alter table membership_level enable row level security;
grant select on membership_level to authenticated;

create policy "membership_level_select_all" on membership_level
  for select
  using (true);
