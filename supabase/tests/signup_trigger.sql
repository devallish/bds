-- Contract test for handle_new_user(): a signup with full metadata
-- auto-creates person + member; role is never taken from metadata (prevents
-- self-escalation); a signup missing required metadata is rejected outright.

begin;
create extension if not exists pgtap with schema extensions;

select plan(4);

-- confirmation_token/recovery_token/email_change_token_new/email_change are
-- set explicitly (not left NULL) so these fixtures could also authenticate
-- via GoTrue if needed — see the comment in seed.sql for why this matters.
insert into auth.users
  (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token, email_change_token_new, email_change)
values
  ('00000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'trigger-test-1@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}',
   jsonb_build_object('first_names', 'Trigger', 'last_name', 'TestOne', 'region_id', (select id from region where label = 'South East')), '', '', '', '');

select is(
  (select first_names from person where user_id = 'b0000000-0000-0000-0000-000000000001'),
  'Trigger',
  'trigger creates a person row from signup metadata'
);

select is(
  (select role from member where id = 'b0000000-0000-0000-0000-000000000001')::text,
  'member',
  'trigger creates a member row defaulting to role=member'
);

-- Attempting to smuggle a role via metadata has no effect — the trigger never
-- reads a 'role' key from metadata at all.
insert into auth.users
  (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data, confirmation_token, recovery_token, email_change_token_new, email_change)
values
  ('00000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'trigger-test-2@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}',
   jsonb_build_object('first_names', 'Trigger', 'last_name', 'TestTwo', 'region_id', (select id from region where label = 'South East'), 'role', 'national_admin'), '', '', '', '');

select is(
  (select role from member where id = 'b0000000-0000-0000-0000-000000000002')::text,
  'member',
  'a role supplied in signup metadata is ignored — cannot self-escalate'
);

select throws_like(
  $$insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data) values ('00000000-0000-0000-0000-000000000000', 'b0000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'trigger-test-3@example.test', crypt('password123', gen_salt('bf')), now(), now(), now(), '{}', '{}')$$,
  '%signup metadata must include%',
  'signup missing required metadata is rejected'
);

select * from finish();
rollback;
