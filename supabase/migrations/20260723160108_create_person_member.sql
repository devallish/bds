-- region: BDS is organised into regions (CLAUDE.md: "region is a first-class
-- field"). Broken out into its own table since it's an entity in its own
-- right, expected to carry more data later (e.g. coordinator assignment,
-- boundaries) — same lookup-table pattern as address_type/membership_level:
-- integer identity id, migration-seeded, not member-authored. Placeholder
-- values pending BDS's actual region list.
create table region (
  id integer generated always as identity primary key,
  label text not null
);

comment on table region is 'Lookup table for BDS regions — placeholder values pending BDS''s actual region list. Expected to gain more columns later.';

insert into region (label) values
  ('National'),
  ('South East'),
  ('North West');

-- person: a member's identity details. Created before member, since a member
-- links to person 1:1 — a member record requires an existing person record.
create table person (
  user_id uuid primary key references auth.users (id) on delete cascade,
  title text,
  first_names text not null,
  last_name text not null,
  date_of_birth date,
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) default auth.uid(),
  edited_at timestamptz,
  edited_by uuid references auth.users (id) on delete set null
);

comment on table person is 'One row per person''s identity details. member links to this table 1:1 (a member is a person).';
comment on column person.created_by is 'Standing convention for all member-authored tables: created_at/created_by required, edited_at/edited_by null until first edit (populated by the set_edited_metadata trigger).';

-- Member table: region and role are first-class per CLAUDE.md's architecture rules
-- (region-based access control, three-tier role model). Other fields are placeholders
-- pending the exact field list from BDS's membership system. Membership tier/level
-- history lives in membership_period, not here — it's time-bound, this table isn't.

create type member_role as enum ('member', 'regional_coordinator', 'national_admin');

create table member (
  id uuid primary key references person (user_id) on delete cascade,
  region_id integer not null references region (id),
  role member_role not null default 'member',
  membership_number text,
  joined_at date,
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) default auth.uid(),
  edited_at timestamptz,
  edited_by uuid references auth.users (id) on delete set null
);

comment on table member is 'One row per member, linked 1:1 to person (a member is a person) via id. region_id and role drive row-level security.';
