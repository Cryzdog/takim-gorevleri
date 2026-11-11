-- Takım Görevleri — veritabanı kurulumu
-- Tablolar, yeni kullanıcı profili ve erişim kuralları.

-- ---------- Tablolar ----------
create table public.profiles (
  id        uuid primary key references auth.users on delete cascade,
  email     text,
  full_name text,
  role      text not null default 'user'
);

create table public.projects (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null default auth.uid() references auth.users on delete cascade,
  name       text not null,
  created_at timestamptz not null default now()
);

create table public.tasks (
  id         uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects on delete cascade,
  title      text not null,
  done       boolean not null default false
);

create index tasks_project_id_idx on public.tasks (project_id);

grant select, insert, update, delete on public.profiles, public.projects, public.tasks to authenticated;

-- ---------- Kayıt olunca profil oluştur ----------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email);
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Satır düzeyi güvenlik ----------
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.tasks    enable row level security;

-- ---------- Profiller ----------
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- ---------- Projeler ----------
create policy projects_select_own on public.projects
  for select to authenticated
  using (owner_id = auth.uid());

-- Yöneticiler tüm projeleri listeleyebilir
create policy projects_select_admin on public.projects
  for select to authenticated
  using (exists (select 1 from public.profiles
                 where id = auth.uid() and role = 'admin'));

create policy projects_insert_own on public.projects
  for insert to authenticated
  with check (owner_id = auth.uid());

create policy projects_update_own on public.projects
  for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy projects_delete_own on public.projects
  for delete to authenticated
  using (owner_id = auth.uid());

-- ---------- Görevler ----------
create policy tasks_select on public.tasks
  for select to authenticated
  using (true);

create policy tasks_insert_own on public.tasks
  for insert to authenticated
  with check (exists (select 1 from public.projects p
                      where p.id = project_id and p.owner_id = auth.uid()));

create policy tasks_update on public.tasks
  for update to authenticated
  using (auth.uid() is not null);

create policy tasks_delete_own on public.tasks
  for delete to authenticated
  using (exists (select 1 from public.projects p
                 where p.id = project_id and p.owner_id = auth.uid()));
