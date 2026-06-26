// Snippeter extension config — the one place to point the extension at a backend.
//
// Defaults target the local dev stack (`supabase start`, see
// ../../docs/local-dev.md). To use a hosted project, change these two values to
//   SUPABASE_URL = "https://<your-project-ref>.supabase.co"
//   ANON_KEY     = "<its-publishable-key>"
// No manifest edit needed: host_permissions already allow http://127.0.0.1/* and
// https://*.supabase.co/*. The anon/publishable key is safe to embed in clients
// — Row Level Security scopes every row to the signed-in user.
export const SUPABASE_URL = "http://127.0.0.1:55321";
export const ANON_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0";
