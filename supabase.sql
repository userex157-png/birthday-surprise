create table if not exists public.vault_state (
  id text primary key,
  target_birthday date,
  milestones jsonb not null default '[]'::jsonb,
  memos jsonb not null default '[]'::jsonb,
  custom_letter_msg text,
  updated_at timestamptz not null default now()
);

create table if not exists public.media (
  id text primary key,
  name text not null,
  type text not null,
  mime_type text,
  caption text,
  timestamp bigint not null,
  is_favorite boolean not null default false,
  url text not null,
  storage_path text not null
);

alter table public.vault_state enable row level security;
alter table public.media enable row level security;

create policy "Authenticated users can read vault"
on public.vault_state for select to authenticated using (true);

create policy "Only admin can write vault"
on public.vault_state for all to authenticated
using ((auth.jwt() ->> 'email') = 'userex157@gmail.com')
with check ((auth.jwt() ->> 'email') = 'userex157@gmail.com');

create policy "Authenticated users can read media"
on public.media for select to authenticated using (true);

create policy "Only admin can write media"
on public.media for all to authenticated
using ((auth.jwt() ->> 'email') = 'userex157@gmail.com')
with check ((auth.jwt() ->> 'email') = 'userex157@gmail.com');

insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

create policy "Authenticated users can read media files"
on storage.objects for select to authenticated
using (bucket_id = 'media');

create policy "Only admin can write media files"
on storage.objects for all to authenticated
using (bucket_id = 'media' and (auth.jwt() ->> 'email') = 'userex157@gmail.com')
with check (bucket_id = 'media' and (auth.jwt() ->> 'email') = 'userex157@gmail.com');

alter publication supabase_realtime add table public.vault_state;
alter publication supabase_realtime add table public.media;
