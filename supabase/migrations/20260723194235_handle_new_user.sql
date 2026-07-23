-- Auto-creates person + member rows when a real signup happens via Supabase
-- Auth (an insert into auth.users). The Flutter AuthRepository adapter is
-- expected to call auth.signUp() with first_names/last_name/region_id (and
-- optionally title/date_of_birth) passed as user metadata:
--   supabase.auth.signUp(email: ..., password: ..., data: {
--     'first_names': ..., 'last_name': ..., 'region_id': ..., 'title': ...,
--     'date_of_birth': ...
--   })
--
-- first_names/last_name/region_id are required — they back NOT NULL columns
-- on person/member, so a signup missing them fails loudly rather than
-- creating a broken row. role is deliberately NEVER read from metadata: it
-- always defaults to 'member'. Metadata is fully caller-controlled, so
-- honouring a caller-supplied role would let anyone self-escalate to
-- regional_coordinator/national_admin at signup. Promotion only happens via
-- the existing member_update_all_national_admin RLS policy (an admin editing
-- the row after the fact).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_first_names text := new.raw_user_meta_data ->> 'first_names';
  v_last_name text := new.raw_user_meta_data ->> 'last_name';
  v_region_id integer := (new.raw_user_meta_data ->> 'region_id')::integer;
  v_title text := new.raw_user_meta_data ->> 'title';
  v_date_of_birth date := (new.raw_user_meta_data ->> 'date_of_birth')::date;
begin
  if v_first_names is null or v_last_name is null or v_region_id is null then
    raise exception 'signup metadata must include first_names, last_name, and region_id';
  end if;

  insert into person (user_id, title, first_names, last_name, date_of_birth, created_by)
  values (new.id, v_title, v_first_names, v_last_name, v_date_of_birth, new.id);

  insert into member (id, region_id, created_by)
  values (new.id, v_region_id, new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();
