-- Pacific Northwest Mother's: public resource suggestion intake
-- Run in the Supabase SQL Editor for the PNWM project.
-- Submissions are private review-queue records; this policy intentionally
-- grants anonymous visitors INSERT only, not SELECT/UPDATE/DELETE.

create table if not exists public.mother_resource_submissions (
  id bigint generated always as identity primary key,
  organization_name text not null check (char_length(trim(organization_name)) between 2 and 160),
  category text not null check (category in ('food','housing','childcare','financial','mental-health','safety','health','other')),
  description text not null check (char_length(trim(description)) between 10 and 1500),
  website text null check (website is null or (char_length(website) <= 500 and website ~* '^https://')),
  phone text null check (phone is null or char_length(phone) <= 60),
  submitter_email text null check (submitter_email is null or char_length(submitter_email) <= 254),
  service_area text null check (service_area is null or char_length(service_area) <= 160),
  review_status text not null default 'pending' check (review_status in ('pending','approved','rejected')),
  created_at timestamptz not null default now()
);

alter table public.mother_resource_submissions enable row level security;

revoke all on table public.mother_resource_submissions from anon, authenticated;
grant insert on table public.mother_resource_submissions to anon, authenticated;
grant usage, select on sequence public.mother_resource_submissions_id_seq to anon, authenticated;

drop policy if exists "Anyone can submit a resource suggestion" on public.mother_resource_submissions;
create policy "Anyone can submit a resource suggestion"
  on public.mother_resource_submissions
  for insert
  to anon, authenticated
  with check (review_status = 'pending');

-- Do not create a public SELECT policy. Review submissions only through a
-- trusted administrator workflow or Supabase Dashboard.
