-- Snippet manager sync schema. Timestamps are epoch-milliseconds (bigint) to
-- match the local Drift schema; owner_id scopes every row to a user (RLS).

create table public.snippets (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null default '',
  body text not null default '',
  type text not null default 'code',
  language_id text,
  purpose text,
  description text,
  collection_id text,
  is_favorite boolean not null default false,
  sort_index integer,
  visibility text not null default 'private',
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  dirty boolean not null default false
);

create table public.snippet_files (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  snippet_id text not null,
  filename text not null default '',
  language_id text,
  content text not null default '',
  position integer not null default 0,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  dirty boolean not null default false
);

create table public.snippet_file_versions (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  snippet_id text not null,
  filename text not null default '',
  language_id text,
  content text not null default '',
  position integer not null default 0,
  saved_at bigint not null,
  dirty boolean not null default false
);

create table public.labels (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null default '',
  normalized_name text not null default '',
  color text,
  parent_id text,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  dirty boolean not null default false
);

create table public.snippet_labels (
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  snippet_id text not null,
  label_id text not null,
  created_at bigint not null,
  primary key (snippet_id, label_id)
);

create table public.collections (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null default '',
  parent_id text,
  icon text,
  color text,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  dirty boolean not null default false
);

create table public.attachments (
  id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  snippet_id text not null,
  filename text not null default '',
  mime_type text not null default '',
  bytes bytea,
  size_bytes integer not null default 0,
  created_at bigint not null,
  updated_at bigint not null,
  deleted_at bigint,
  dirty boolean not null default false
);

create table public.ai_prompt_meta (
  snippet_id text primary key,
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  target_model text,
  model_provider text,
  system_prompt text,
  temperature double precision,
  max_tokens integer,
  variables_json text not null default '[]',
  updated_at bigint not null
);

-- Incremental-sync indexes.
create index snippets_owner_updated_idx on public.snippets (owner_id, updated_at);
create index snippet_files_owner_updated_idx on public.snippet_files (owner_id, updated_at);
create index snippet_files_snippet_idx on public.snippet_files (snippet_id);
create index snippet_file_versions_owner_snippet_idx on public.snippet_file_versions (owner_id, snippet_id);
create index labels_owner_updated_idx on public.labels (owner_id, updated_at);
create index snippet_labels_owner_snippet_idx on public.snippet_labels (owner_id, snippet_id);
create index collections_owner_updated_idx on public.collections (owner_id, updated_at);
create index attachments_owner_snippet_idx on public.attachments (owner_id, snippet_id);

-- Row-level security: each user sees and writes only their own rows.
alter table public.snippets enable row level security;
alter table public.snippet_files enable row level security;
alter table public.snippet_file_versions enable row level security;
alter table public.labels enable row level security;
alter table public.snippet_labels enable row level security;
alter table public.collections enable row level security;
alter table public.attachments enable row level security;
alter table public.ai_prompt_meta enable row level security;

create policy own_all on public.snippets for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.snippet_files for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.snippet_file_versions for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.labels for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.snippet_labels for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.collections for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.attachments for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_all on public.ai_prompt_meta for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- Realtime change broadcasting (cross-device live sync).
alter publication supabase_realtime add table
  public.snippets,
  public.snippet_files,
  public.snippet_file_versions,
  public.labels,
  public.snippet_labels,
  public.collections,
  public.attachments,
  public.ai_prompt_meta;
