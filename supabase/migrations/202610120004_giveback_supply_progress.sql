-- Keep published item totals synchronized with the private supply ledger.
-- Only authorized staff can write the ledger; public clients cannot call this function.

alter table public.pnwm_giveback_supply_log
  drop constraint if exists pnwm_giveback_supply_log_action_check;
alter table public.pnwm_giveback_supply_log
  add constraint pnwm_giveback_supply_log_action_check
  check (action in (
    'collected','distributed',
    'correction_collected_add','correction_collected_remove',
    'correction_distributed_add','correction_distributed_remove'
  ));

create or replace function public.pnwm_refresh_giveback_supply_totals()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_slug text;
  v_collected integer;
  v_distributed integer;
begin
  if tg_op = 'DELETE' then
    v_slug := old.project_slug;
  else
    v_slug := new.project_slug;
  end if;

  select greatest(0, coalesce(sum(
    case action
      when 'collected' then quantity
      when 'correction_collected_add' then quantity
      when 'correction_collected_remove' then -quantity
      else 0
    end
  ),0))::integer
  into v_collected
  from public.pnwm_giveback_supply_log
  where project_slug = v_slug;

  select greatest(0, coalesce(sum(
    case action
      when 'distributed' then quantity
      when 'correction_distributed_add' then quantity
      when 'correction_distributed_remove' then -quantity
      else 0
    end
  ),0))::integer
  into v_distributed
  from public.pnwm_giveback_supply_log
  where project_slug = v_slug;

  update public.pnwm_giveback_projects
    set collected_items = v_collected,
        distributed_items = v_distributed,
        last_verified_at = now(),
        updated_at = now()
    where slug = v_slug;

  if tg_op = 'DELETE' then return old; else return new; end if;
end;
$$;

revoke all on function public.pnwm_refresh_giveback_supply_totals() from public, anon, authenticated;
drop trigger if exists pnwm_refresh_giveback_supply_totals on public.pnwm_giveback_supply_log;
create trigger pnwm_refresh_giveback_supply_totals
after insert or update or delete on public.pnwm_giveback_supply_log
for each row execute function public.pnwm_refresh_giveback_supply_totals();
