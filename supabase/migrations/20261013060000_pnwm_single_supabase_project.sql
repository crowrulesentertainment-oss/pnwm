-- Consolidate PNWM content and form tables in the approved project:
-- cevylpnoexugwgygvtgu. No other Supabase project is used by the PNWM site.
begin;

create table if not exists public.mother_resources (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 category text not null,
 description text not null,
 website text,
 phone text,
 service_area text,
 verified boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.mother_resource_submissions (
 id uuid primary key default gen_random_uuid(),
 organization_name text not null,
 category text not null,
 description text not null,
 website text,
 phone text,
 submitter_email text,
 service_area text,
 review_status text not null default 'pending' check (review_status in ('pending','reviewing','approved','declined','spam')),
 admin_notes text,
 created_at timestamptz not null default now()
);
create table if not exists public.mother_events (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text,
 event_date timestamptz,
 location text,
 event_type text,
 category text,
 status text not null default 'draft' check (status in ('draft','planning','published','cancelled','archived')),
 registration_url text,
 registration_link text,
 website_url text,
 url text,
 created_at timestamptz not null default now()
);
create table if not exists public.mother_programs (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 description text,
 service_area text,
 status text not null default 'draft' check (status in ('draft','active','paused','closed','archived')),
 active boolean not null default false,
 category text,
 website_url text,
 website text,
 signup_url text,
 registration_url text,
 url text,
 created_at timestamptz not null default now()
);
create table if not exists public.mother_support_requests (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(btrim(name)) between 1 and 120),
 email text not null check (char_length(btrim(email)) between 3 and 254),
 category text not null check (char_length(category) between 1 and 100),
 location text,
 message text not null check (char_length(message) between 1 and 2000),
 status text not null default 'new' check (status in ('new','reviewing','contacted','resolved','spam','archived')),
 created_at timestamptz not null default now()
);
create table if not exists public.mother_meeting_interest (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(btrim(name)) between 1 and 120),
 email text not null check (char_length(btrim(email)) between 3 and 254),
 city text,
 created_at timestamptz not null default now()
);
create table if not exists public.mother_volunteers (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(btrim(name)) between 1 and 120),
 email text not null check (char_length(btrim(email)) between 3 and 254),
 city text,
 interests text,
 status text not null default 'new' check (status in ('new','reviewing','contacted','approved','declined','spam')),
 created_at timestamptz not null default now()
);
create table if not exists public.mother_partners (
 id uuid primary key default gen_random_uuid(),
 organization_name text not null check (char_length(btrim(organization_name)) between 1 and 180),
 contact_name text,
 email text not null check (char_length(btrim(email)) between 3 and 254),
 description text,
 status text not null default 'new' check (status in ('new','reviewing','contacted','approved','declined','spam')),
 created_at timestamptz not null default now()
);

alter table public.mother_resources enable row level security;
alter table public.mother_resource_submissions enable row level security;
alter table public.mother_events enable row level security;
alter table public.mother_programs enable row level security;
alter table public.mother_support_requests enable row level security;
alter table public.mother_meeting_interest enable row level security;
alter table public.mother_volunteers enable row level security;
alter table public.mother_partners enable row level security;

drop policy if exists "Public reads verified resources" on public.mother_resources;
create policy "Public reads verified resources" on public.mother_resources
 for select to anon, authenticated using (verified = true);
drop policy if exists "Public reads visible events" on public.mother_events;
create policy "Public reads visible events" on public.mother_events
 for select to anon, authenticated using (status in ('published','planning'));
drop policy if exists "Public reads active programs" on public.mother_programs;
create policy "Public reads active programs" on public.mother_programs
 for select to anon, authenticated using (active = true);

drop policy if exists "Public submits resource suggestions" on public.mother_resource_submissions;
create policy "Public submits resource suggestions" on public.mother_resource_submissions
 for insert to anon, authenticated with check (
   review_status = 'pending' and admin_notes is null
   and char_length(btrim(organization_name)) between 1 and 160
   and char_length(btrim(category)) between 1 and 80
   and char_length(btrim(description)) between 1 and 1500
   and (website is null or char_length(website) <= 500)
   and (phone is null or char_length(phone) <= 60)
   and (submitter_email is null or char_length(submitter_email) <= 254)
   and (service_area is null or char_length(service_area) <= 160)
 );
drop policy if exists "Public submits support requests" on public.mother_support_requests;
create policy "Public submits support requests" on public.mother_support_requests
 for insert to anon, authenticated with check (
   status = 'new' and char_length(btrim(name)) between 1 and 120
   and char_length(btrim(email)) between 3 and 254
   and char_length(category) between 1 and 100
   and (location is null or char_length(location) <= 160)
   and char_length(message) between 1 and 2000
 );
drop policy if exists "Public submits meeting interest" on public.mother_meeting_interest;
create policy "Public submits meeting interest" on public.mother_meeting_interest
 for insert to anon, authenticated with check (
   char_length(btrim(name)) between 1 and 120
   and char_length(btrim(email)) between 3 and 254
   and (city is null or char_length(city) <= 160)
 );
drop policy if exists "Public submits volunteer interest" on public.mother_volunteers;
create policy "Public submits volunteer interest" on public.mother_volunteers
 for insert to anon, authenticated with check (
   status = 'new' and char_length(btrim(name)) between 1 and 120
   and char_length(btrim(email)) between 3 and 254
   and (city is null or char_length(city) <= 160)
   and (interests is null or char_length(interests) <= 2000)
 );
drop policy if exists "Public submits partner interest" on public.mother_partners;
create policy "Public submits partner interest" on public.mother_partners
 for insert to anon, authenticated with check (
   status = 'new' and char_length(btrim(organization_name)) between 1 and 180
   and (contact_name is null or char_length(contact_name) <= 120)
   and char_length(btrim(email)) between 3 and 254
   and (description is null or char_length(description) <= 2000)
 );

revoke all on public.mother_resources, public.mother_resource_submissions,
 public.mother_events, public.mother_programs, public.mother_support_requests,
 public.mother_meeting_interest, public.mother_volunteers, public.mother_partners
 from public, anon, authenticated;
grant select on public.mother_resources, public.mother_events, public.mother_programs to anon, authenticated;
grant insert (organization_name, category, description, website, phone, submitter_email, service_area, review_status)
 on public.mother_resource_submissions to anon, authenticated;
grant insert (name, email, category, location, message, status)
 on public.mother_support_requests to anon, authenticated;
grant insert (name, email, city) on public.mother_meeting_interest to anon, authenticated;
grant insert (name, email, city, interests) on public.mother_volunteers to anon, authenticated;
grant insert (organization_name, contact_name, email, description) on public.mother_partners to anon, authenticated;

commit;
