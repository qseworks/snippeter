-- Each membership row carries the member's email (set by that user on join),
-- so the app can show member emails without admin auth.users access.
alter table public.workspace_members add column email text not null default '';
