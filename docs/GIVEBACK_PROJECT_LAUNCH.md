# PNWM Give-back Projects — Launch Runbook

## Purpose

Launch **Mother & Baby Essentials** as a volunteer-led, in-kind supply-drive initiative serving the South Sound and Western Washington. This is a community project, not a cash fundraiser. The public website accepts volunteer interest and project suggestions; it does not accept payments.

## Launch gates

Do not announce a public collection date or drop-off address until all of the following are true:

1. A named project coordinator is responsible for intake, storage, inventory, volunteer communications, and issue escalation.
2. At least one family-serving organization has confirmed in writing that it wants to receive a specific list of supplies, its packaging/condition rules, delivery process, and the date/time it can accept a delivery.
3. The project has a secure, dry, clean storage plan and a way to track every accepted item.
4. The public page shows the approved needs list, what is not being accepted, the contact route, and the last verified progress date.
5. Volunteer roles, safety rules, and a privacy notice are in place.
6. PNWM has reviewed applicable state/local requirements for collecting in-kind charitable contributions and has decided whether registration or another arrangement is needed.

## Suggested first partner conversations

These are **potential contacts only, not confirmed PNWM partners**. Contact them first and ask what they need; do not deliver items without agreement.

- [Multicultural Child & Family Hope Center diaper bank](https://mcfhc.org/diaper-bank/) — Tacoma; the Pierce County Early Childhood Network lists its diaper bank hours and contact details.
- [Pregnancy Aid of Washington — Find Us](https://pregnancyaidwa.org/FindUs.html) — includes the Tacoma location and regional offices.
- [Tacoma-Pierce County Health Department Family Support Centers](https://tpchd.org/health/family/family-support-partnership/family-support-centers/) — lists family resource centers and diaper/wipe support.

Ask each partner:
- Which items are needed this month, in what sizes and quantities?
- Must items be new, unopened, or in original packaging?
- What items can never be accepted?
- What delivery windows, intake forms, and receipts/acknowledgements are available?
- Would they prefer PNWM to collect supplies or direct donors to their own program?
- May PNWM identify them publicly as a partner? Obtain written permission before doing so.

## Initial item acceptance policy

Use a partner-approved list that can change as needs change. A conservative starter list to discuss with a partner is:
- New, unopened diapers in requested sizes.
- New, unopened baby wipes.
- New, unopened hygiene supplies specifically requested by the receiving organization.
- Clean baby clothing only when the partner confirms it can accept used clothing and identifies sizes/condition rules.

Do **not** accept opened products, expired products, medication, recalled items, used car seats, cribs, sleep products, or formula unless a qualified receiving partner has expressly confirmed a safe and lawful acceptance process. Never promise that an item will be delivered to a particular family. Refer urgent or specialized needs to established service providers.

## Website and Supabase data model

The migration files are in `supabase/migrations/`:
- `202610120003_pnwm_giveback_projects.sql`
- `202610120004_giveback_supply_progress.sql`

The project database is the PNWM requests Supabase project. Tables:

| Table | Purpose | Public access |
|---|---|---|
| `pnwm_giveback_projects` | Public project details and aggregate item counts | Read published rows only |
| `pnwm_giveback_updates` | Approved project updates | Read published updates only |
| `pnwm_giveback_volunteer_signups` | Names, email, location, volunteer interest, status | Insert constrained fields only; no public read/update/delete |
| `pnwm_giveback_ideas` | Community project suggestions and review status | Insert constrained fields only; no public read/update/delete |
| `pnwm_giveback_supply_log` | Private supply inventory ledger | No public access |

The website uses the aggregate project row for public counts. Supply ledger triggers recalculate collected/distributed totals and update the verification timestamp. The public volunteer-interest count is deliberately a manually reviewed aggregate to avoid showing a misleading number caused by spam or unreviewed submissions.

### Record accepted or delivered supplies

Use the Supabase SQL Editor with an authorized staff account. Never put an admin/service-role key in the website.

Example: record 24 units collected after they have been physically received and checked:
```sql
insert into public.pnwm_giveback_supply_log
  (project_slug, action, item_category, quantity, note)
values
  ('mother-baby-essentials', 'collected', 'New diapers — size 3', 24,
   'Received, counted, and checked against current partner request');
```

Example: record 18 units delivered and acknowledged by the receiving organization:
```sql
insert into public.pnwm_giveback_supply_log
  (project_slug, action, item_category, quantity, partner_name, note)
values
  ('mother-baby-essentials', 'distributed', 'New diapers — size 3', 18,
   'Partner name recorded internally',
   'Delivery accepted by partner; acknowledgement retained internally');
```

Use correction actions only to correct a previously logged count; add a note explaining the reason. Never include a family's name, contact details, health information, or case details in the ledger. For each public metric, be able to reconcile the total to ledger entries.

To publish an update, insert it as `draft`, review it for privacy and accuracy, then change its status to `published` and set `published_at = now()`. Update project descriptions/targets only through an authorized administrative session. The target defaults to zero intentionally: do not invent a goal before a partner-approved quantity is agreed.

After reviewing volunteer submissions, update the public aggregate only with a defensible count of distinct, valid volunteer interests:
```sql
update public.pnwm_giveback_projects
set volunteer_count_public = 0, updated_at = now()
where slug = 'mother-baby-essentials';
```
Replace `0` with the verified count; do not expose names or contact information.

## Privacy and volunteer safeguards

- Collect only the information needed to contact volunteers: name, email, general area, interest, and optional availability.
- Never ask the public to submit recipient names, addresses, diagnoses, immigration details, custody details, or financial hardship narratives.
- Keep all submissions private; only authorized coordinators should access them.
- Set a retention policy (for example, delete declined or inactive volunteer submissions after a documented period) and honor deletion requests where legally appropriate.
- Use two-adult/partner-supervised handling practices; volunteers should not have unsupervised access to children or private family records.
- Confirm volunteer expectations, safe lifting/transportation, photo consent, and any background-screening requirements before assigning a role.
- Obtain explicit permission before using a partner's name/logo or publishing photographs. Avoid photos identifying recipients without informed consent.
- Publish only aggregate outcomes; no identifiable recipient stories or images by default.

## Transparency standard

Publish:
- Current partner-approved item needs and the date confirmed.
- Accepted item counts and delivered item counts, reconciled to the private ledger.
- The date the counts were last verified.
- What remains unconfirmed, including whether a partner relationship or delivery has not yet been agreed.
- Corrections when a public count or update was inaccurate.

Do not publish dollar-equivalent values, “families helped,” or impact claims unless a documented method supports them. Items collected are not the same as items distributed or families served.

## Legal and financial boundaries

PNWM is currently operating this project as a supply-drive and volunteer initiative. The website must not solicit or accept money for this project, describe items as tax-deductible, imply PNWM is a registered charity, or suggest that an independent organization has endorsed the project.

Washington's Charitable Solicitations Act can apply to organizations soliciting contributions for charitable purposes, with exemptions that depend on specific conditions. Consult the Washington Secretary of State's current [charitable organization FAQ](https://www.sos.wa.gov/corporations-charities/frequently-asked-questions-faqs/charitable-organizations) and [self-assessment guide](https://www.sos.wa.gov/corporations-charities/nonprofits-charities/charities/starting-charity/self-assessment-guide-charitable-organizations) before public solicitation. Recheck requirements before adding cash, online payments, sponsorship funds, raffles, paid fundraisers, or a broader multi-state campaign.

## Phased launch

### Phase 1 — Set up (week 1)
- Appoint a project coordinator and one backup.
- Contact 2–3 potential recipient organizations.
- Agree on the first needs list and written delivery process.
- Confirm data access and test a volunteer submission with a designated test entry, then remove the test record.

### Phase 2 — Small pilot (weeks 2–3)
- Invite a small known group of volunteers.
- Collect only partner-requested supplies at a controlled location/time.
- Log and inspect each intake; segregate unsuitable items for return/recycling rather than distribution.
- Deliver the first batch to the partner and obtain acknowledgement.

### Phase 3 — Publish verified progress (week 3 onward)
- Reconcile inventory before publishing totals.
- Publish a short update describing the supply categories, collection dates, and confirmed delivery (without identifying recipients).
- Review the needs list with the partner before each new collection window.

### Phase 4 — Expand carefully
- Add additional South Sound locations only after local logistics and recipient partners are confirmed.
- Add other projects only through the community suggestion review process.
- Revisit legal, insurance, storage, volunteer, and privacy requirements before materially expanding operations.

## Definition of a successful first month

- One recipient organization has confirmed the items it can accept.
- One small, safe collection cycle has been completed.
- All received and delivered items are logged and reconciled.
- Volunteers are contacted through a private workflow.
- The public page displays verified counts and at least one factual update.
- No cash is collected and no partner is represented as affiliated without permission.
