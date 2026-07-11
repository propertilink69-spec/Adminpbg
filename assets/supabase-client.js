// ============================================================
// Isi dua nilai ini dengan kredensial project Supabase kamu.
// Ambil dari: Supabase Dashboard > Settings > API
// ============================================================
const SUPABASE_URL = "https://svzincvhyhgiwnevihrr.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_G8n6kq8i66lxk2GzosLzig_ugZunqt2";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const DOC_CATEGORIES = [
  { key: "ktp", label: "KTP Pemohon" },
  { key: "stra_skk", label: "Sertifikat Tenaga Ahli (STRA/SKK)" },
  { key: "gambar_arsitektur", label: "Gambar Arsitektur" },
  { key: "gambar_struktur", label: "Gambar Struktur" },
  { key: "hitungan_struktur", label: "Hitungan Struktur" },
  { key: "mep", label: "MEP" },
  { key: "revisi", label: "File Revisian" },
  { key: "dokumen_lain", label: "Dokumen Lain" },
];

// Redirect ke login jika belum login ATAU bukan admin.
// Dipanggil di setiap halaman dashboard/project.
async function requireAdmin() {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) {
    window.location.href = "index.html";
    return null;
  }
  const { data: profile, error } = await supabaseClient
    .from("profiles")
    .select("role, full_name")
    .eq("id", session.user.id)
    .single();

  if (error || !profile || profile.role !== "admin") {
    await supabaseClient.auth.signOut();
    window.location.href = "index.html?denied=1";
    return null;
  }
  return { session, profile };
}

async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = "index.html";
}

function escapeHtml(str) {
  return String(str ?? "").replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
  }[c]));
}
