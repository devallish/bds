-- Synthetic fixture data only, per CLAUDE.md: "Real member data must never appear
-- in tests, fixtures, or CI." Runs as the postgres superuser, which bypasses RLS.

insert into auth.users
  (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
values
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'test-national-admin@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}'),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'test-coordinator-south-east@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}'),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'test-coordinator-north-west@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}'),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'test-member-south-east-1@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}'),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'test-member-south-east-2@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}'),
  ('00000000-0000-0000-0000-000000000000', 'a0000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated', 'test-member-north-west-1@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}');

insert into person (user_id, title, first_names, last_name, date_of_birth, created_by)
values
  ('a0000000-0000-0000-0000-000000000001', 'Mx', 'Test', 'NationalAdmin', '1975-01-01', 'a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'Ms', 'Test', 'CoordinatorSouthEast', '1980-02-02', 'a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003', 'Mr', 'Test', 'CoordinatorNorthWest', '1982-03-03', 'a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004', 'Mrs', 'Test', 'MemberSouthEastOne', '1990-04-04', 'a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005', 'Mr', 'Test', 'MemberSouthEastTwo', '1991-05-05', 'a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006', 'Ms', 'Test', 'MemberNorthWestOne', '1992-06-06', 'a0000000-0000-0000-0000-000000000006');

insert into members (user_id, region, role, membership_number, joined_at, created_by)
values
  ('a0000000-0000-0000-0000-000000000001', 'National', 'national_admin', 'BDS-0001', '2020-01-15', 'a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'South East', 'regional_coordinator', 'BDS-0002', '2021-03-01', 'a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003', 'North West', 'regional_coordinator', 'BDS-0003', '2021-06-10', 'a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004', 'South East', 'member', 'BDS-0004', '2023-02-20', 'a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005', 'South East', 'member', 'BDS-0005', '2023-05-05', 'a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006', 'North West', 'member', 'BDS-0006', '2022-11-11', 'a0000000-0000-0000-0000-000000000006');

insert into membership_period (member_user_id, membership_level_id, effective_from, effective_to, created_by)
values
  ('a0000000-0000-0000-0000-000000000001', 'life', '2020-01-15', '2027-01-15', 'a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'individual', '2026-03-01', '2027-02-28', 'a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003', 'individual', '2026-06-10', '2027-06-09', 'a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004', 'family', '2026-02-20', '2027-02-19', 'a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005', 'individual', '2026-05-05', '2027-05-04', 'a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006', 'junior', '2026-11-11', '2027-11-10', 'a0000000-0000-0000-0000-000000000006');

insert into address (person_id, address_type_id, line_1, town, county, postcode, created_by)
values
  ('a0000000-0000-0000-0000-000000000001', 'home', '1 Test Street', 'Testville', 'Testshire', 'TE1 1ST', 'a0000000-0000-0000-0000-000000000001'),
  ('a0000000-0000-0000-0000-000000000002', 'home', '2 Test Street', 'Southtown', 'Kent', 'TE2 2ST', 'a0000000-0000-0000-0000-000000000002'),
  ('a0000000-0000-0000-0000-000000000003', 'home', '3 Test Street', 'Northtown', 'Lancashire', 'TE3 3ST', 'a0000000-0000-0000-0000-000000000003'),
  ('a0000000-0000-0000-0000-000000000004', 'home', '4 Test Street', 'Southtown', 'Kent', 'TE4 4ST', 'a0000000-0000-0000-0000-000000000004'),
  ('a0000000-0000-0000-0000-000000000005', 'home', '5 Test Street', 'Southtown', 'Kent', 'TE5 5ST', 'a0000000-0000-0000-0000-000000000005'),
  ('a0000000-0000-0000-0000-000000000006', 'home', '6 Test Street', 'Northtown', 'Lancashire', 'TE6 6ST', 'a0000000-0000-0000-0000-000000000006');
