# Propertylink — Dashboard Admin PBG/SLF

Aplikasi statis (HTML + JS) untuk manajemen klien dan dokumen pengajuan PBG/SLF.
Login dan penyimpanan file memakai **Supabase** (gratis untuk skala kecil).
Tidak ada halaman publik/pendaftaran — hanya admin yang bisa masuk.

## Struktur File

```
propertylink-app/
├── index.html          → halaman login
├── dashboard.html       → daftar proyek klien
├── project.html         → detail proyek + upload dokumen
├── schema.sql            → skema database untuk Supabase
├── assets/
│   ├── style.css
│   └── supabase-client.js   → isi kredensial Supabase di sini
└── README.md (file ini)
```

## Langkah Setup

### 1. Buat project Supabase
1. Buka [supabase.com](https://supabase.com) → Sign up / login → **New Project**.
2. Beri nama bebas (mis. `propertylink`), buat password database, pilih region terdekat (Singapore).
3. Tunggu sampai project selesai dibuat (~2 menit).

### 2. Jalankan skema database
1. Di dashboard project, buka menu **SQL Editor** → **New query**.
2. Salin seluruh isi file `schema.sql` dari folder ini, tempel, lalu klik **Run**.
   - Ini akan membuat tabel `profiles`, `projects`, `documents`, plus aturan keamanan (RLS) supaya hanya admin yang bisa akses data.

### 3. Buat bucket penyimpanan file
1. Buka menu **Storage** → **New bucket**.
2. Nama bucket: `client-documents` (harus persis sama).
3. Pilih **Private bucket** (jangan dicentang public).
4. Setelah bucket dibuat, kembali ke **SQL Editor**, jalankan bagian paling bawah dari `schema.sql` (blok "storage_admin_..." policy) jika belum otomatis ikut terjalankan.

### 4. Buat akun admin pertama
1. Buka menu **Authentication** → **Users** → **Add user** → **Create new user**.
2. Isi email dan password untuk akun admin kamu. Centang "Auto Confirm User".
3. Setelah user dibuat, salin **User UID** miliknya.
4. Buka **SQL Editor**, jalankan query berikut (ganti `USER_UID_DISINI` dan nama):
   ```sql
   insert into profiles (id, full_name, role)
   values ('USER_UID_DISINI', 'Nama Admin', 'admin');
   ```
5. Ulangi langkah ini untuk setiap admin tambahan yang kamu percaya.

### 5. Ambil kredensial API
1. Buka menu **Settings** → **API**.
2. Salin **Project URL** dan **anon public key**.
3. Buka file `assets/supabase-client.js` di proyek ini, ganti dua baris di paling atas:
   ```js
   const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
   const SUPABASE_ANON_KEY = "eyJhbGciOi...";
   ```

### 6. Coba jalankan lokal (opsional)
Buka `index.html` langsung di browser, atau pakai extension "Live Server" di VS Code. Login pakai akun admin yang dibuat di langkah 4.

## Deploy ke GitHub Pages

1. Buat repository baru di GitHub, upload seluruh isi folder `propertylink-app/` ke repo tersebut (lewat GitHub Desktop, web upload, atau `git push`).
2. Di repo, buka **Settings** → **Pages**.
3. Pada **Source**, pilih branch `main` dan folder `/ (root)`, lalu **Save**.
4. Tunggu 1-2 menit, GitHub akan memberi URL seperti `https://namakamu.github.io/nama-repo/`.
5. Buka URL tersebut → akan langsung diarahkan ke halaman login.

## Catatan Keamanan

- `anon public key` Supabase memang aman ditaruh di kode frontend (bukan rahasia) — akses sebenarnya dikontrol lewat Row Level Security (RLS) yang sudah diatur di `schema.sql`, bukan oleh key ini.
- Jangan pernah menaruh **service_role key** Supabase di file frontend manapun.
- Tidak ada form pendaftaran di aplikasi ini. Admin baru hanya bisa dibuat manual lewat Supabase Dashboard (langkah 4).
- Bucket `client-documents` bersifat private — file hanya bisa diakses lewat aplikasi oleh admin yang login.

## Kategori Dokumen yang Didukung

- KTP Pemohon
- Sertifikat Tenaga Ahli (STRA/SKK)
- Gambar Arsitektur
- Gambar Struktur
- Hitungan Struktur
- MEP
- File Revisian
- Dokumen Lain

Format file yang diterima: JPG, PNG, PDF — maksimal 10MB per file.
