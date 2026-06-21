-- #4: Lock owner_id on the 8 data tables so it cannot be spoofed.
--     INSERT  -> owner_id forced to the caller (auth.uid()).
--     UPDATE  -> owner_id pinned to the existing value (no re-attribution).
--     Service-role writes (auth.uid() is null) keep the supplied value.
create or replace function private.lock_owner_id()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    new.owner_id := coalesce(auth.uid(), new.owner_id);
  else
    new.owner_id := old.owner_id;
  end if;
  return new;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array[
    'snippets','snippet_files','snippet_file_versions','labels',
    'snippet_labels','collections','attachments','ai_prompt_meta'
  ]
  loop
    execute format('drop trigger if exists trg_lock_owner_id on public.%I', t);
    execute format(
      'create trigger trg_lock_owner_id before insert or update on public.%I '
      'for each row execute function private.lock_owner_id()', t);
  end loop;
end $$;

-- #3: Only the snippet owner or a workspace manager may TRANSITION a snippet
--     to visibility='public'. Editing an already-public snippet is unaffected,
--     and creating your own public snippet (you are the owner) is allowed.
create or replace function private.guard_snippet_visibility()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.visibility = 'public'
     and old.visibility is distinct from 'public'
     and auth.uid() is not null
     and not (
          old.owner_id = auth.uid()
       or (new.workspace_id is not null and private.can_manage(new.workspace_id))
     )
  then
    raise exception
      'only the snippet owner or a workspace manager can make a snippet public';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guard_snippet_visibility on public.snippets;
create trigger trg_guard_snippet_visibility
  before update on public.snippets
  for each row execute function private.guard_snippet_visibility();
