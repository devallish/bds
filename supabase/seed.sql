-- Synthetic fixture data only, per CLAUDE.md: "Real member data must never appear
-- in tests, fixtures, or CI." Runs as the postgres superuser, which bypasses RLS.

-- raw_user_meta_data drives the handle_new_user() trigger, which auto-creates
-- the person + member rows below — this also exercises the trigger as part of
-- every db reset, rather than bypassing it with direct inserts.
--
-- confirmation_token/recovery_token/email_change_token_new/email_change have
-- no column default and are left NULL unless set explicitly here. GoTrue's Go
-- code scans them as plain (non-nullable) strings, so a NULL — harmless for
-- direct SQL/pgTAP access — makes any real sign-in against these fixtures
-- fail with a 500 "Database error querying schema".
insert into auth.users
  (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token, email_change_token_new, email_change)
values
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'test-national-admin@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', jsonb_build_object('title', 'Mx', 'first_names', 'Test', 'last_name', 'NationalAdmin', 'date_of_birth', '1975-01-01', 'region_id', (select id from region where label = 'National')), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'test-coordinator-south-east@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', jsonb_build_object('title', 'Ms', 'first_names', 'Test', 'last_name', 'CoordinatorSouthEast', 'date_of_birth', '1980-02-02', 'region_id', (select id from region where label = 'South East')), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'test-coordinator-north-west@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', jsonb_build_object('title', 'Mr', 'first_names', 'Test', 'last_name', 'CoordinatorNorthWest', 'date_of_birth', '1982-03-03', 'region_id', (select id from region where label = 'North West')), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'test-member-south-east-1@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', jsonb_build_object('title', 'Mrs', 'first_names', 'Test', 'last_name', 'MemberSouthEastOne', 'date_of_birth', '1990-04-04', 'region_id', (select id from region where label = 'South East')), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'test-member-south-east-2@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', jsonb_build_object('title', 'Mr', 'first_names', 'Test', 'last_name', 'MemberSouthEastTwo', 'date_of_birth', '1991-05-05', 'region_id', (select id from region where label = 'South East')), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated', 'test-member-north-west-1@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', jsonb_build_object('title', 'Ms', 'first_names', 'Test', 'last_name', 'MemberNorthWestOne', 'date_of_birth', '1992-06-06', 'region_id', (select id from region where label = 'North West')), '', '', '', '');

-- The trigger always creates member.role = 'member' and leaves
-- membership_number/joined_at unset (deliberately — role escalation and
-- membership numbering are staff-administered, not signup-time data). Set
-- them here to reflect these fixtures' intended roles.
update member set role = 'national_admin', membership_number = 'BDS-0001', joined_at = '2020-01-15' where id = 'a0000000-0000-0000-0000-000000000001';
update member set role = 'regional_coordinator', membership_number = 'BDS-0002', joined_at = '2021-03-01' where id = 'a0000000-0000-0000-0000-000000000002';
update member set role = 'regional_coordinator', membership_number = 'BDS-0003', joined_at = '2021-06-10' where id = 'a0000000-0000-0000-0000-000000000003';
update member set membership_number = 'BDS-0004', joined_at = '2023-02-20' where id = 'a0000000-0000-0000-0000-000000000004';
update member set membership_number = 'BDS-0005', joined_at = '2023-05-05' where id = 'a0000000-0000-0000-0000-000000000005';
update member set membership_number = 'BDS-0006', joined_at = '2022-11-11' where id = 'a0000000-0000-0000-0000-000000000006';

insert into membership_period (member_id, membership_level_id, effective_from, effective_to, created_by)
values
  ('a0000000-0000-0000-0000-000000000001', (select id from membership_level where label = 'Life'), '2020-01-15', '2027-01-15', 'a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', (select id from membership_level where label = 'Individual'), '2026-03-01', '2027-02-28', 'a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003', (select id from membership_level where label = 'Individual'), '2026-06-10', '2027-06-09', 'a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004', (select id from membership_level where label = 'Family'), '2026-02-20', '2027-02-19', 'a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005', (select id from membership_level where label = 'Individual'), '2026-05-05', '2027-05-04', 'a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006', (select id from membership_level where label = 'Junior'), '2026-11-11', '2027-11-10', 'a0000000-0000-0000-0000-000000000006');

insert into address (person_id, address_type_id, line_1, town, county, postcode, created_by)
values
  ('a0000000-0000-0000-0000-000000000001', (select id from address_type where label = 'Home'), '1 Test Street', 'Testville', 'Testshire', 'TE1 1ST', 'a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', (select id from address_type where label = 'Home'), '2 Test Street', 'Southtown', 'Kent', 'TE2 2ST', 'a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003', (select id from address_type where label = 'Home'), '3 Test Street', 'Northtown', 'Lancashire', 'TE3 3ST', 'a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004', (select id from address_type where label = 'Home'), '4 Test Street', 'Southtown', 'Kent', 'TE4 4ST', 'a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005', (select id from address_type where label = 'Home'), '5 Test Street', 'Southtown', 'Kent', 'TE5 5ST', 'a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006', (select id from address_type where label = 'Home'), '6 Test Street', 'Northtown', 'Lancashire', 'TE6 6ST', 'a0000000-0000-0000-0000-000000000006');
