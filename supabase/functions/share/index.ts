// Public share page for snippets with visibility='public'. No auth required for
// readers (deploy with --no-verify-jwt); uses the service role but only ever
// exposes public, non-deleted snippets.
//
// Deploy (either):
//   supabase functions deploy share --no-verify-jwt --project-ref xxxxxxxxxxxxxxxxxxxx
// or approve the equivalent Supabase MCP deploy_edge_function call.
//
// Reader URL: https://xxxxxxxxxxxxxxxxxxxx.supabase.co/functions/v1/share?id=<snippetId>
import { createClient } from "npm:@supabase/supabase-js@2";

const esc = (s: string) =>
  String(s ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");

function page(title: string, body: string, status = 200): Response {
  const doc = `<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<style>
  :root{color-scheme:light dark}
  body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
    max-width:860px;margin:0 auto;padding:32px 20px;line-height:1.6;
    color:#1b1b1f;background:#fbfbfd}
  @media (prefers-color-scheme:dark){body{color:#e6e8ec;background:#111016}}
  h1{font-size:1.7rem;margin:0 0 4px}
  .meta{color:#7a8190;font-size:.85rem;margin-bottom:24px}
  .desc{margin:0 0 24px;white-space:pre-wrap}
  .file{margin:18px 0;border:1px solid #2a2e3a33;border-radius:12px;overflow:hidden}
  .file h3{margin:0;padding:10px 14px;font-size:.85rem;font-weight:600;
    background:#16b37814;color:#0e8f5e;border-bottom:1px solid #2a2e3a22}
  pre{margin:0;padding:14px;overflow:auto;background:#0d1117;color:#e6edf3}
  code{font-family:'JetBrains Mono',ui-monospace,SFMono-Regular,Menlo,monospace;font-size:.85rem}
  .badge{display:inline-block;background:#16b37822;color:#0e8f5e;border-radius:6px;
    padding:1px 7px;font-size:.72rem;margin-left:8px;vertical-align:middle}
  footer{margin-top:36px;color:#7a8190;font-size:.8rem;border-top:1px solid #2a2e3a22;padding-top:14px}
</style></head><body>${body}
<footer>Shared via <strong>Snippet Manager</strong></footer></body></html>`;
  return new Response(doc, {
    status,
    headers: { "content-type": "text/html; charset=utf-8", "cache-control": "public, max-age=60" },
  });
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  const id = url.searchParams.get("id") ??
    url.pathname.split("/").filter(Boolean).pop();
  if (!id || id === "share") {
    return page("Snippet not found", "<h1>Snippet not found</h1><p>Missing snippet id.</p>", 200);
  }
  const sb = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data: snip } = await sb
    .from("snippets").select("title,description,body")
    .eq("id", id).eq("visibility", "public").is("deleted_at", null)
    .maybeSingle();
  if (!snip) {
    return page("Snippet not found",
      "<h1>Snippet not found</h1><p>This snippet is private or does not exist.</p>", 200);
  }
  const { data: files } = await sb
    .from("snippet_files").select("filename,content")
    .eq("snippet_id", id).is("deleted_at", null)
    .order("position", { ascending: true });
  const list = (files && files.length ? files : [{ filename: "", content: snip.body ?? "" }]);
  const filesHtml = list.map((f: Record<string, unknown>) =>
    `<div class="file"><h3>${esc((f.filename as string) || "untitled")}</h3>` +
    `<pre><code>${esc(f.content as string)}</code></pre></div>`).join("");
  const desc = snip.description
    ? `<div class="desc">${esc(snip.description)}</div>` : "";
  const body = `<h1>${esc(snip.title || "Untitled")}<span class="badge">public</span></h1>` +
    `<div class="meta">${list.length} file${list.length === 1 ? "" : "s"}</div>` +
    desc + filesHtml;
  return page(snip.title || "Snippet", body);
});
