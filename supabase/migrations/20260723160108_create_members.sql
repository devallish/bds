-- person: a member's identity details. Created before members, since a member
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

comment on table person is 'One row per person''s identity details. members links to this table 1:1 (a member is a person).';
comment on column person.created_by is 'Standing convention for all member-authored tables: created_at/created_by required, edited_at/edited_by null until first edit (populated by the set_edited_metadata trigger).';

-- Members table: region and role are first-class per CLAUDE.md's architecture rules
-- (region-based access control, three-tier role model). Other fields are placeholders
-- pending the exact field list from BDS's membership system. Membership tier/level
-- history lives in membership_period, not here — it's time-bound, this table isn't.

create type member_role as enum ('member', 'regional_coordinator', 'national_admin');

create table members (
  user_id uuid primary key references person (user_id) on delete cascade,
  region text not null,
  role member_role not null default 'member',
  membership_number text,
  joined_at date,
  created_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) default auth.uid(),
  edited_at timestamptz,
  edited_by uuid references auth.users (id) on delete set null
);

comment on table members is 'One row per member, linked 1:1 to person (a member is a person). region and role drive row-level security.';
comment on column members.region is 'Placeholder text field until BDS''s canonical region list is confirmed.';
