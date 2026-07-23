-- RLS contract test: asserts cross-region and cross-role access is DENIED, not
-- just that same-role/same-region access succeeds, per CLAUDE.md's priority
-- coverage. Also covers the set_edited_metadata trigger. Runs against the
-- seeded synthetic fixtures in seed.sql.

begin;
create extension if not exists pgtap with schema extensions;

select plan(20);

-- Plain member (South East) sees only their own row across all four tables.
set local role authenticated;
set local request.jwt.claim.sub = 'a0000000-0000-0000-0000-000000000004';

select is(
  (select count(*) from member)::int,
  1,
  'member sees exactly one member row'
);

select is(
  (select id from member limit 1)::text,
  'a0000000-0000-0000-0000-000000000004',
  'the member row a member sees is their own'
);

select is(
  (select count(*) from person)::int,
  1,
  'member sees exactly one person row (their own)'
);

select is(
  (select count(*) from address)::int,
  1,
  'member sees exactly one address row (their own)'
);

select is(
  (select count(*) from membership_period)::int,
  1,
  'member sees exactly one membership_period row (their own)'
);

-- set_edited_metadata trigger: a no-op update still populates edited_at/edited_by.
update member set region_id = region_id where id = 'a0000000-0000-0000-0000-000000000004';

select ok(
  (select edited_at from member where id = 'a0000000-0000-0000-0000-000000000004') is not null,
  'edited_at is populated after an update'
);

select is(
  (select edited_by from member where id = 'a0000000-0000-0000-0000-000000000004')::text,
  'a0000000-0000-0000-0000-000000000004',
  'edited_by reflects the acting user'
);

-- South East regional coordinator sees their region (self + 2 members), not North West.
set local request.jwt.claim.sub = 'a0000000-0000-0000-0000-000000000002';

select is(
  (select count(*) from member)::int,
  3,
  'south east coordinator sees exactly their region''s members'
);

select is(
  (select count(*) from member where region_id = (select id from region where label = 'North West'))::int,
  0,
  'south east coordinator cannot see north west members'
);

select is(
  (select count(*) from person)::int,
  3,
  'south east coordinator sees exactly their region''s person rows'
);

select is(
  (select count(*) from person where user_id = 'a0000000-0000-0000-0000-000000000003')::int,
  0,
  'south east coordinator cannot see the north west coordinator''s person row'
);

select is(
  (select count(*) from address)::int,
  3,
  'south east coordinator sees exactly their region''s address rows'
);

select is(
  (select count(*) from address where person_id = 'a0000000-0000-0000-0000-000000000003')::int,
  0,
  'south east coordinator cannot see the north west coordinator''s address'
);

select is(
  (select count(*) from membership_period)::int,
  3,
  'south east coordinator sees exactly their region''s membership_period rows'
);

select is(
  (select count(*) from membership_period where member_id = 'a0000000-0000-0000-0000-000000000003')::int,
  0,
  'south east coordinator cannot see the north west coordinator''s membership_period'
);

-- National admin sees everyone, across all four tables.
set local request.jwt.claim.sub = 'a0000000-0000-0000-0000-000000000001';

select is(
  (select count(*) from member)::int,
  6,
  'national admin sees all members across all regions'
);

select is(
  (select count(*) from person)::int,
  6,
  'national admin sees all person rows across all regions'
);

select is(
  (select count(*) from address)::int,
  6,
  'national admin sees all address rows across all regions'
);

select is(
  (select count(*) from membership_period)::int,
  6,
  'national admin sees all membership_period rows across all regions'
);

-- Exclusion constraint: a member cannot hold two overlapping membership_period rows.
select throws_like(
  $$insert into membership_period (member_id, membership_level_id, effective_from, effective_to) values ('a0000000-0000-0000-0000-000000000004', (select id from membership_level where label = 'Family'), '2026-06-01', '2027-05-31')$$,
  '%exclusion constraint%',
  'overlapping membership_period for the same member is rejected'
);

select * from finish();
rollback;
