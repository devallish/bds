-- address_type is a lookup table rather than an enum, unlike member_role:
-- address types (home/postal/work/...) are the kind of reference data BDS staff
-- may reasonably want to extend without an engineering deploy, whereas
-- member_role is tightly coupled to the RLS logic above and isn't meant to be
-- casually extended. It's static, migration-seeded data, so it doesn't carry
-- the created_by/edited_by audit convention applied to member-authored tables.
-- Uses a plain integer identity id rather than a uuid, unlike member-authored
-- tables — it's never generated client-side/offline, so there's no collision
-- risk to design around.
create table address_type (
  id integer generated always as identity primary key,
  label text not null
);

comment on table address_type is 'Lookup table for address types (home, postal, etc.) — static reference data, extendable without a code deploy.';

insert into address_type (label) values
  ('Home'),
  ('Postal'),
  ('Correspondence'),
  ('Work');

create table address (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references person (user_id) on delete cascade,
  address_type_id integer not null references address_type (id),
  line_1 text not null,
  line_2 text,
  line_3 text,
  line_4 text,
  town text not null,
  county text,
  postcode text not null,
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) default auth.uid(),
  edited_at timestamptz,
  edited_by uuid references auth.users (id) on delete set null
);

comment on table address is 'A person can have multiple addresses distinguished by address_type_id (home, postal, etc.).';

create trigger address_set_edited_metadata
  before update on address
  for each row
  execute function public.set_edited_metadata();

alter table address enable row level security;
grant select, insert, update on address to authenticated;

create policy "address_select_own" on address
  for select
  using (person_id = auth.uid());

create policy "address_select_region_coordinator" on address
  for select
  using (get_my_role() = 'regional_coordinator' and region_of(person_id) = get_my_region_id());

create policy "address_select_all_national_admin" on address
  for select
  using (get_my_role() = 'national_admin');

create policy "address_update_own" on address
  for update
  using (person_id = auth.uid())
  with check (person_id = auth.uid());

create policy "address_update_all_national_admin" on address
  for update
  using (get_my_role() = 'national_admin')
  with check (get_my_role() = 'national_admin');

create policy "address_insert_national_admin" on address
  for insert
  with check (get_my_role() = 'national_admin');

-- address_type is static reference data: readable by any authenticated user,
-- not writable outside a migration (no insert/update policy defined).
alter table address_type enable row level security;
grant select on address_type to authenticated;

create policy "address_type_select_all" on address_type
  for select
  using (true);
