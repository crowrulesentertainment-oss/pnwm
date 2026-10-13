-- PNWM Give-back Projects: supply-drive project data and private submissions.
-- This migration intentionally does not create any cash-donation or payment flow.

create table if not exists public.pnwm_giveback_projects (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null check (char_length(title) between 3 and 160),
  description text not null default '',
  service_area text not null default 'South Sound / Western Washington',
  status text not null default 'draft' check (status in ('draft','published','archived')),
  target_items integer not null default 0 check (target_items >= 0),
  collected_items integer not null default 0 check (collected_items >= 0),
  distributed_items integer not null default 0 check (distributed_items >= 0),
  volunteer_count_public integer not null default 0 check (volunteer_count_public >= 0),
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pnwm_giveback_updates (
  id uuid primary key default gen_random_uuid(),
  project_slug text not null references public.pnwm_giveback_projects(slug) on update cascade on delete cascade,
  title text not null check (char_length(title) between 3 and 160),
  body text not null check (char_length(body) between 1 and 2000),
  status text not null default 'draft' check (status in ('draft','published','archived')),
  published_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.pnwm_giveback_volunteer_signups (
  id uuid primary key default gen_random_uuid(),
  project_slug text not null default 'mother-baby-essentials',
  name text not null check (char_length(name) between 2 and 120),
  email text not null check (char_length(email) between 3 and 254),
  area text not null check (char_length(area) between 2 and 120),
  interest text not null check (interest in ('sorting','drive','delivery','outreach','remote','other')),
  availability text check (availability is null or char_length(availability) <= 240),
  consent boolean not null default false check (consent = true),
  status text not null default 'pending' check (status in ('pending','approved','contacted','declined')),
  created_at timestamptz not null default now()
);

create table if not exists public.pnwm_giveback_ideas (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 160),
  area text not null check (char_length(area) between 2 and 120),
  description text not null check (char_length(description) between 10 and 1800),
  email text check (email is null or char_length(email) <= 254),
  consent boolean not null default false check (consent = true),
  status text not null default 'pending' check (status in ('pending','reviewing','approved','declined')),
  created_at timestamptz not null default now()
);

-- Private ledger for staff/authorized admins to record received and partner-delivered supplies.
create table if not exists public.pnwm_giveback_supply_log (
  id uuid primary key default gen_random_uuid(),
  project_slug text not null default 'mother-baby-essentials' references public.pnwm_giveback_projects(slug) on update cascade on delete restrict,
  action text not null check (action in ('collected','distributed','adjustment')),
  item_category text not null check (char_length(item_category) between 2 and 100),
  quantity integer not null check (quantity > 0 and quantity <= 100000),
  partner_name text,
  note text,
  recorded_by text,
  created_at timestamptz not null default now()
);

alter table public.pnwm_giveback_projects enable row level security;
alter table public.pnwm_giveback_updates enable row level security;
alter table public.pnwm_giveback_volunteer_signups enable row level security;
alter table public.pnwm_giveback_ideas enable row level security;
alter table public.pnwm_giveback_supply_log enable row level security;

drop policy if exists "Published give-back projects are public" on public.pnwm_giveback_projects;
create policy "Published give-back projects are public"
  on public.pnwm_giveback_projects for select to anon, authenticated
  using (status = 'published');

drop policy if exists "Published updates for published projects are public" on public.pnwm_giveback_updates;
create policy "Published updates for published projects are public"
  on public.pnwm_giveback_updates for select to anon, authenticated
  using (
    status = 'published'
    and exists (
      select 1 from public.pnwm_giveback_projects p
      where p.slug = project_slug and p.status = 'published'
    )
  );

drop policy if exists "Public may submit volunteer interest" on public.pnwm_giveback_volunteer_signups;
create policy "Public may submit volunteer interest"
  on public.pnwm_giveback_volunteer_signups for insert to anon, authenticated
  with check (
    status = 'pending'
    and consent = true
    and project_slug = 'mother-baby-essentials'
    and char_length(name) between 2 and 120
    and char_length(email) between 3 and 254
    and char_length(area) between 2 and 120
  );

drop policy if exists "Public may submit project ideas for review" on public.pnwm_giveback_ideas;
create policy "Public may submit project ideas for review"
  on public.pnwm_giveback_ideas for insert to anon, authenticated
  with check (
    status = 'pending'
    and consent = true
    and char_length(title) between 3 and 160
    and char_length(area) between 2 and 120
    and char_length(description) between 10 and 1800
  );

-- Explicit grants: public users can only read published project/update data and
-- insert the specific fields allowed by the two intake forms. No public reads,
-- updates, or deletes are granted for submissions or the supply ledger.
revoke all on public.pnwm_giveback_projects from anon, authenticated;
revoke all on public.pnwm_giveback_updates from anon, authenticated;
revoke all on public.pnwm_giveback_volunteer_signups from anon, authenticated;
revoke all on public.pnwm_giveback_ideas from anon, authenticated;
revoke all on public.pnwm_giveback_supply_log from anon, authenticated;

grant select on public.pnwm_giveback_projects to anon, authenticated;
grant select on public.pnwm_giveback_updates to anon, authenticated;
grant insert (project_slug, name, email, area, interest, availability, consent, status)
  on public.pnwm_giveback_volunteer_signups to anon, authenticated;
grant insert (title, area, description, email, consent, status)
  on public.pnwm_giveback_ideas to anon, authenticated;

insert into public.pnwm_giveback_projects
  (slug, title, description, service_area, status, target_items, collected_items, distributed_items, volunteer_count_public)
values
  ('mother-baby-essentials',
   'Mother & Baby Essentials',
   'A volunteer-led supply drive for partner-confirmed diapers, wipes, baby clothing, and other requested essentials.',
   'South Sound / Western Washington',
   'published', 0, 0, 0, 0)
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  service_area = excluded.service_area,
  status = 'published',
  updated_at = now();
