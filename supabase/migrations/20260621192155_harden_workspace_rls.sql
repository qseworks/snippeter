-- Harden workspace RLS.
--
-- 1) Privilege-escalation fix: the workspace_members INSERT policy let an
--    invited user choose ANY role (member -> manager/owner) because the
--    self-join branch never tied the inserted role to the invite's role.
--    Bind i.role = workspace_members.role so an invitee can only take the
--    exact role they were invited with. Managers (can_manage) are unchanged.
--
-- 2) Hide the SECURITY DEFINER helpers (is_member/can_write/can_manage) from
--    the public PostgREST API by moving them to a non-exposed `private`
--    schema. RLS policies reference these functions by OID, and
--    ALTER FUNCTION ... SET SCHEMA preserves the OID (and the EXECUTE grants),
--    so all existing policies keep working without being rewritten, while
--    /rest/v1/rpc/{is_member,can_write,can_manage} stop being exposed.

-- 1) Privilege-escalation fix --------------------------------------------
drop policy if exists "ins" on public.workspace_members;
create policy "ins" on public.workspace_members
  for insert to public
  with check (
    public.can_manage(workspace_id)
    or (
      user_id = auth.uid()
      and exists (
        select 1
        from public.workspace_invites i
        where i.workspace_id = workspace_members.workspace_id
          and lower(i.email) = lower(auth.email())
          and i.role = workspace_members.role
      )
    )
  );

-- 2) Move helpers out of the API-exposed schema --------------------------
create schema if not exists private;
grant usage on schema private to anon, authenticated, service_role;

alter function public.is_member(text)  set schema private;
alter function public.can_write(text)  set schema private;
alter function public.can_manage(text) set schema private;
