# PNWM event and program request review

The public homepage writes to two private Supabase tables:

- `public.mother_event_registration_requests`
- `public.mother_program_application_requests`

Run the migration in `supabase/migrations/202610120002_event_registration_program_applications.sql` against the Supabase project configured by the PNWM homepage. Do not run it against a different CrowRules project.

## Review pending requests

In Supabase Dashboard → SQL Editor, run the relevant read-only query:

```sql
select id, item_title, name, email, phone, attendees, message, created_at
from public.mother_event_registration_requests
where review_status = 'pending'
order by created_at asc;
```

```sql
select id, item_title, name, email, phone, message, created_at
from public.mother_program_application_requests
where review_status = 'pending'
order by created_at asc;
```

These requests contain personal contact details. Keep results private and do not copy them into public pages, logs, or public issue trackers.

## Approve or update a request

Use the UUID from the review query and only update after an authorized person has reviewed the request.

```sql
update public.mother_event_registration_requests
set review_status = 'approved', reviewed_at = now()
where id = 'REPLACE-WITH-REQUEST-UUID'
  and review_status in ('pending', 'reviewing');
```

```sql
update public.mother_program_application_requests
set review_status = 'approved', reviewed_at = now()
where id = 'REPLACE-WITH-REQUEST-UUID'
  and review_status in ('pending', 'reviewing');
```

Valid statuses are `pending`, `reviewing`, `approved`, `waitlisted`, `declined`, `contacted`, and `spam`. To add internal notes, set `admin_notes = '...' ` in the same update. Do not add public SELECT/UPDATE policies: public users must not be able to enumerate or alter submissions.

## Security notes

- The public form can INSERT pending requests only.
- RLS is enabled; public roles are not granted SELECT, UPDATE, or DELETE.
- The form includes a honeypot field and validates required fields.
- A successful insert confirms receipt, not acceptance or a reserved place.
- This repository change does not itself install the migration or prove that the live Supabase project has been configured. Apply the migration to the exact project configured by the website, then test one submission and verify that anonymous SELECT is denied.
