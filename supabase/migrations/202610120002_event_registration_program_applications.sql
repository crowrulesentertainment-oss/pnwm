-- PNWM event registration requests and program application requests.
-- Public visitors may submit requests, but cannot read, update, or delete submissions.
-- Review and status changes are performed by authorized administrators in the Supabase Dashboard SQL Editor.
begin;

create table if not exists public.mother_event_registration_requests (
  id uuid primary key default gen_random_uuid(),
  item_id text,
  item_title text not null check (char_length(btrim(item_title)) between 1 and 200),
  name text not null check (char_length(btrim(name)) between 1 and 120),
  email text not null check (char_length(btrim(email)) between 3 and 254),
  phone text check (phone is null or char_length(phone) <= 40),
  attendees smallint not null default 1 check (attendees between 1 and 5),
  message text check (message is null or char_length(message) <= 1500),
  review_status text not null default 'pending' check (review_status in ('pending','reviewing','approved','waitlisted','declined','contacted','spam')),
  admin_notes text,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.mother_program_application_requests (
  id uuid primary key default gen_random_uuid(),
  item_id text,
  item_title text not null check (char_length(btrim(item_title)) between 1 and 200),
  name text not null check (char_length(btrim(name)) between 1 and 120),
  email text not null check (char_length(btrim(email)) between 3 and 254),
  phone text check (phone is null or char_length(phone) <= 40),
  message text check (message is null or char_length(message) <= 1500),
  review_status text not null default 'pending' check (review_status in ('pending','reviewing','approved','waitlisted','declined','contacted','spam')),
  admin_notes text,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.mother_event_registration_requests enable row level security;
alter table public.mother_program_application_requests enable row level security;

revoke all on public.mother_event_registration_requests from anon, authenticated;
revoke all on public.mother_program_application_requests from anon, authenticated;
grant insert on public.mother_event_registration_requests to anon, authenticated;
grant insert on public.mother_program_application_requests to anon, authenticated;

drop policy if exists "Public may submit pending event registration requests" on public.mother_event_registration_requests;
create policy "Public may submit pending event registration requests"
on public.mother_event_registration_requests
for insert to anon, authenticated
with check (
  review_status = 'pending'
  and char_length(btrim(item_title)) between 1 and 200
  and char_length(btrim(name)) between 1 and 120
  and char_length(btrim(email)) between 3 and 254
  and attendees between 1 and 5
);

drop policy if exists "Public may submit pending program applications" on public.mother_program_application_requests;
create policy "Public may submit pending program applications"
on public.mother_program_application_requests
for insert to anon, authenticated
with check (
  review_status = 'pending'
  and char_length(btrim(item_title)) between 1 and 200
  and char_length(btrim(name)) between 1 and 120
  and char_length(btrim(email)) between 3 and 254
);

comment on table public.mother_event_registration_requests is 'Private event registration requests. Review in the Supabase Dashboard; never expose submissions publicly.';
comment on table public.mother_program_application_requests is 'Private program interest/application requests. Review in the Supabase Dashboard; never expose submissions publicly.';

commit;
