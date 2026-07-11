-- ============================================================
-- Propertylink — Skema Database Supabase
-- Jalankan seluruh file ini di Supabase Dashboard > SQL Editor
-- ============================================================

create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- Tabel profiles (menyimpan role tiap akun; hanya "admin" yang dipakai)
-- ------------------------------------------------------------
create table if not exists profiles (
  id uuid references auth.users(id) primary key,
  full_name text,
  role text not null default 'admin',
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- Tabel projects (data pengajuan per klien)
-- ------------------------------------------------------------
create table if not exists projects (
  id uuid primary key default uuid_generate_v4(),
  client_name text not null,
  client_phone text,
  client_address text,
  jenis text not null check (jenis in ('PBG','SLF')),
  status text not null default 'Proses' check (status in ('Proses','Selesai','Dibatalkan')),
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- Tabel documents (file per kategori per proyek)
-- ------------------------------------------------------------
create table if not exists documents (
  id uuid primary key default uuid_generate_v4(),
  project_id uuid references projects(id) on delete cascade,
  category text not null check (category in (
    'ktp','stra_skk','gambar_arsitektur','gambar_struktur',
    'hitungan_struktur','mep','revisi','dokumen_lain'
  )),
  file_name text not null,
  file_path text not null,
  status text not null default 'lengkap' check (status in ('lengkap','perlu_revisi')),
  uploaded_by uuid references profiles(id),
  uploaded_at timestamptz default now()
);

-- ------------------------------------------------------------
-- Aktifkan Row Level Security
-- ------------------------------------------------------------
alter table profiles enable row level security;
alter table projects enable row level security;
alter table documents enable row level security;

-- Fungsi bantu: cek apakah user yang login adalah admin
create or replace function is_admin() returns boolean as $$
  select exists (
    select 1 from profiles where id = auth.uid() and role = 'admin'
  );
$$ language sql security definer;

-- Kebijakan akses: hanya admin yang bisa apa-apa
drop policy if exists "profile_self_select" on profiles;
create policy "profile_self_select" on profiles
  for select using (auth.uid() = id);

drop policy if exists "projects_admin_all" on projects;
create policy "projects_admin_all" on projects
  for all using (is_admin()) with check (is_admin());

drop policy if exists "documents_admin_all" on documents;
create policy "documents_admin_all" on documents
  for all using (is_admin()) with check (is_admin());

-- ============================================================
-- LANGKAH MANUAL (tidak bisa lewat SQL):
-- 1. Buka Storage > Create bucket > nama: client-documents > Private (jangan public)
-- 2. Setelah bucket dibuat, jalankan blok SQL di bawah ini
-- ============================================================

drop policy if exists "storage_admin_insert" on storage.objects;
create policy "storage_admin_insert" on storage.objects
  for insert with check (bucket_id = 'client-documents' and is_admin());

drop policy if exists "storage_admin_select" on storage.objects;
create policy "storage_admin_select" on storage.objects
  for select using (bucket_id = 'client-documents' and is_admin());

drop policy if exists "storage_admin_update" on storage.objects;
create policy "storage_admin_update" on storage.objects
  for update using (bucket_id = 'client-documents' and is_admin());

drop policy if exists "storage_admin_delete" on storage.objects;
create policy "storage_admin_delete" on storage.objects
  for delete using (bucket_id = 'client-documents' and is_admin());
