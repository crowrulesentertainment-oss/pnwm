-- Restrict public PNWM registration/application submissions to fields used by the public form.
-- Public visitors must not be able to set internal review notes, review timestamps, IDs, or created_at.
begin;

drop policy if exists "Public may submit pending event registration requests"
  on public.mother_event_registration_requests;
create policy "Public may submit pending event registration requests"
  on public.mother_event_registration_requests
  for insert to anon, authenticated
  with check (
    review_status = 'pending'
    and admin_notes is null
    and reviewed_at is null
    and char_length(btrim(item_title)) between 1 and 200
    and char_length(btrim(name)) between 1 and 120
    and char_length(btrim(email)) between 3 and 254
    and (phone is null or char_length(phone) <= 40)
    and (message is null or char_length(message) <= 2000)
    and attendees between 1 and 5
  );

drop policy if exists "Public may submit pending program applications"
  on public.mother_program_application_requests;
create policy "Public may submit pending program applications"
  on public.mother_program_application_requests
  for insert to anon, authenticated
  with check (
    review_status = 'pending'
    and admin_notes is null
    and reviewed_at is null
    and char_length(btrim(item_title)) between 1 and 200
    and char_length(btrim(name)) between 1 and 120
    and char_length(btrim(email)) between 3 and 254
    and (phone is null or char_length(phone) <= 40)
    and (message is null or char_length(message) <= 2000)
  );

revoke all privileges on table public.mother_event_registration_requests from public, anon, authenticated;
revoke all privileges on table public.mother_program_application_requests from public, anon, authenticated;

revoke insert (id, item_id, item_title, name, email, phone, attendees, message, review_status, admin_notes, reviewed_at, created_at)
  on table public.mother_event_registration_requests from public, anon, authenticated;
revoke insert (id, item_id, item_title, name, email, phone, message, review_status, admin_notes, reviewed_at, created_at)
  on table public.mother_program_application_requests from public, anon, authenticated;

grant insert (item_id, item_title, name, email, phone, attendees, message, review_status)
  on table public.mother_event_registration_requests to anon, authenticated;
grant insert (item_id, item_title, name, email, phone, message, review_status)
  on table public.mother_program_application_requests to anon, authenticated;

commit;