-- Team libraries + roles. NULL workspace_id on content = personal (owner-only);
-- non-null = a team workspace governed by workspace_members.role.

create table public.workspaces (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null default '',
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  dirty boolean not null default false
);

create table public.workspace_members (
  workspace_id text not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member',  -- owner | manager | member | viewer
  created_at bigint not null,
  primary key (workspace_id, user_id)
);

create table public.workspace_invites (
  id text primary key,
  workspace_id text not null references public.workspaces(id) on delete cascade,
  email text not null,
  role text not null default 'member',
  invited_by uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at bigint not null
);
create index workspace_invites_email_idx on public.workspace_invites (lower(email));

-- workspace_id on every content table (NULL = personal).
alter table public.snippets add column workspace_id text;
alter table public.snippet_files add column workspace_id text;
alter table public.collections add column workspace_id text;
alter table public.labels add column workspace_id text;
alter table public.snippet_labels add column workspace_id text;
alter table public.ai_prompt_meta add column workspace_id text;
alter table public.attachments add column workspace_id text;
alter table public.snippet_file_versions add column workspace_id text;

-- SECURITY DEFINER helpers avoid RLS recursion on workspace_members.
create or replace function public.is_member(ws text)
returns boolean language sql security definer stable set search_path = public as $fn$
  select exists(select 1 from workspace_members m where m.workspace_id = ws and m.user_id = auth.uid());
$fn$;

create or replace function public.can_write(ws text)
returns boolean language sql security definer stable set search_path = public as $fn$
  select exists(select 1 from workspace_members m
    where m.workspace_id = ws and m.user_id = auth.uid() and m.role in ('owner','manager','member'));
$fn$;

create or replace function public.can_manage(ws text)
returns boolean language sql security definer stable set search_path = public as $fn$
  select exists(select 1 from workspace_members m
      where m.workspace_id = ws and m.user_id = auth.uid() and m.role in ('owner','manager'))
    or exists(select 1 from workspaces w where w.id = ws and w.owner_id = auth.uid());
$fn$;

-- Content RLS: personal-owner OR team access (read = member, write = can_write).
do $do$
declare t text;
begin
  foreach t in array array['snippets','snippet_files','collections','labels','snippet_labels','ai_prompt_meta','attachments','snippet_file_versions'] loop
    execute format('drop policy if exists own_all on public.%I', t);
    execute format($p$create policy sel on public.%I for select using ((workspace_id is null and owner_id = auth.uid()) or (workspace_id is not null and public.is_member(workspace_id)))$p$, t);
    execute format($p$create policy ins on public.%I for insert with check ((workspace_id is null and owner_id = auth.uid()) or (workspace_id is not null and public.can_write(workspace_id)))$p$, t);
    execute format($p$create policy upd on public.%I for update using ((workspace_id is null and owner_id = auth.uid()) or (workspace_id is not null and public.can_write(workspace_id))) with check ((workspace_id is null and owner_id = auth.uid()) or (workspace_id is not null and public.can_write(workspace_id)))$p$, t);
    execute format($p$create policy del on public.%I for delete using ((workspace_id is null and owner_id = auth.uid()) or (workspace_id is not null and public.can_write(workspace_id)))$p$, t);
  end loop;
end $do$;

-- workspaces
alter table public.workspaces enable row level security;
create policy sel on public.workspaces for select using (owner_id = auth.uid() or public.is_member(id));
create policy ins on public.workspaces for insert with check (owner_id = auth.uid());
create policy upd on public.workspaces for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy del on public.workspaces for delete using (owner_id = auth.uid());

-- workspace_members
alter table public.workspace_members enable row level security;
create policy sel on public.workspace_members for select using (user_id = auth.uid() or public.is_member(workspace_id));
create policy ins on public.workspace_members for insert with check (
  public.can_manage(workspace_id)
  or (user_id = auth.uid() and exists(select 1 from public.workspace_invites i
        where i.workspace_id = workspace_members.workspace_id and lower(i.email) = lower(auth.email())))
);
create policy upd on public.workspace_members for update using (public.can_manage(workspace_id)) with check (public.can_manage(workspace_id));
create policy del on public.workspace_members for delete using (public.can_manage(workspace_id) or user_id = auth.uid());

-- workspace_invites
alter table public.workspace_invites enable row level security;
create policy sel on public.workspace_invites for select using (lower(email) = lower(auth.email()) or public.can_manage(workspace_id));
create policy ins on public.workspace_invites for insert with check (public.can_manage(workspace_id));
create policy del on public.workspace_invites for delete using (public.can_manage(workspace_id) or lower(email) = lower(auth.email()));

-- Realtime for the new tables.
alter publication supabase_realtime add table public.workspaces, public.workspace_members, public.workspace_invites;
