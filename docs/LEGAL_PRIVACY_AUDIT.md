# PNWM Legal & Privacy Compliance Pass

**Review date:** October 12, 2026  
**Scope:** Public homepage copy, legal/privacy disclosures, visible form notices, and accessible Supabase request-table permissions.  
**Important:** This is a technical and content review, not a legal opinion or a guarantee of compliance.

## Completed in this pass

- Removed the old homepage section describing money/revenue flowing to PNWM and CrowRules Entertainment.
- Replaced copy implying that people need to give money with non-monetary participation language.
- Made the Give-back navigation and section names consistent.
- Added an explicit statement that PNWM does not request or accept money, payments, monetary donations, financial pledges, crowdfunding, or fundraising contributions through the website.
- Added privacy.html and legal.html and linked them from the homepage/footer.
- Added privacy-policy notices to the resource suggestion, event/program request, support, volunteer/partner, meeting-interest, and give-back form experiences.
- Added supabase/migrations/20261013050000_tighten_pnwm_public_request_insert_grants.sql and applied the matching migration to Supabase project cevylpnoexugwgygvtgu.

## Database permission checks completed

For mother_event_registration_requests and mother_program_application_requests in cevylpnoexugwgygvtgu:

- Row-level security is enabled.
- Public policies permit inserts only when the request remains pending and values pass the defined validation checks.
- Public table-level grants are absent after the migration.
- Public insert grants are limited to the fields needed by the public form.
- Public clients no longer have insert grants for internal admin_notes, reviewed_at, id, or created_at fields.
- The policies also require admin_notes and reviewed_at to remain null for public submissions.
- The public submission tables have no public read/update/delete policy in the reviewed schema.

For the pnwm_giveback_* tables in that same project, RLS is enabled. Published project/update data is readable; volunteer/idea submissions are insert-only for public roles; the supply ledger has no public policies or public column grants.

## Not yet verified / required before calling the site fully reviewed

1. The homepage also uses a second Supabase project for mother_resources, mother_resource_submissions, mother_events, mother_programs, mother_support_requests, mother_meeting_interest, mother_volunteers, and mother_partners. The connected Supabase workspace did not grant access to inspect that project. Its RLS policies, table/column grants, retention settings, and any stored data still need a separate review.
2. The published GitHub Pages experience could not be confirmed end-to-end in this pass. The repository files and inline JavaScript syntax were checked, but each form should still be tested in a real browser, including successful submission, invalid input, failure states, mobile layouts, keyboard navigation, and privacy links.
3. Confirm the real-world operator/contact details, who is authorized to read form submissions, how deletion requests are handled, and a documented retention schedule. The published privacy policy must match actual operations.
4. Confirm whether PNWM is operated as an informal initiative, sole proprietorship, LLC, corporation, or another structure; do not imply nonprofit or tax-exempt status without proper basis.
5. Before any physical item collection or delivery, confirm partner approval in writing, item acceptance rules, storage/transport safety, volunteer supervision, and applicable Washington/local requirements.
6. Have Washington counsel review the initiative's actual activities and policies if a legal assurance is needed.

## Operating rule

PNWM's website should remain strictly non-monetary: no donation/payment links, fundraising appeals, crowdfunding, cash pledges, paid sponsorship requests, or claims that any contribution is tax-deductible. Resource listings about third-party financial assistance are informational resources for families and are not a solicitation by PNWM.