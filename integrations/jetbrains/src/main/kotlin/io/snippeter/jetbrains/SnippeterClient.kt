package io.snippeter.jetbrains

import org.json.JSONArray
import org.json.JSONObject
import java.net.URI
import java.net.URLEncoder
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse
import java.nio.charset.StandardCharsets
import java.time.Duration
import java.util.UUID

/** A code snippet row from PostgREST. */
data class Snippet(
    val id: String,
    val title: String,
    val body: String,
    val languageId: String,
    val description: String,
)

/** A snippet_files row from PostgREST. */
data class SnippetFile(
    val id: String,
    val snippetId: String,
    val filename: String,
    val languageId: String,
    val content: String,
    val position: Int,
)

/** Raised for any non-success HTTP response so callers can show a balloon. */
class SnippeterException(message: String) : Exception(message)

/**
 * Thin Supabase (PostgREST + GoTrue) client for the JVM.
 *
 * Uses only the JDK [HttpClient] and org.json — no supabase-js. Every authed
 * read/write transparently refreshes the access token once on a 401 and retries.
 */
object SnippeterClient {

    // Backend connection. Defaults to the local dev stack (`supabase start`, see
    // docs/local-dev.md). Point at a hosted project via a JVM system property or
    // an environment variable (system property wins):
    //   -Dsnippeter.supabaseUrl=https://<ref>.supabase.co   or  SNIPPET_SUPABASE_URL
    //   -Dsnippeter.supabaseAnonKey=<publishable-key>        or  SNIPPET_SUPABASE_ANON_KEY
    // The publishable (anon) key is safe to embed in clients.
    private val SUPABASE_URL: String =
        System.getProperty("snippeter.supabaseUrl")
            ?: System.getenv("SNIPPET_SUPABASE_URL")
            ?: "http://127.0.0.1:55321"
    private val ANON_KEY: String =
        System.getProperty("snippeter.supabaseAnonKey")
            ?: System.getenv("SNIPPET_SUPABASE_ANON_KEY")
            ?: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

    private val REST_BASE = "$SUPABASE_URL/rest/v1"
    private val AUTH_BASE = "$SUPABASE_URL/auth/v1"

    private const val SNIPPET_SELECT =
        "id,title,body,type,language_id,description,visibility,is_favorite,created_at,updated_at,workspace_id"
    private const val FILE_SELECT =
        "id,snippet_id,filename,language_id,content,position"

    private val http: HttpClient = HttpClient.newBuilder()
        .connectTimeout(Duration.ofSeconds(20))
        .build()

    // ---------------------------------------------------------------------
    // Auth (GoTrue)
    // ---------------------------------------------------------------------

    /**
     * Signs in with email + password via the GoTrue password grant and persists
     * the returned tokens in [SessionStore]. Throws [SnippeterException] on failure.
     */
    fun signIn(email: String, password: String) {
        val payload = JSONObject()
            .put("email", email)
            .put("password", password)
            .toString()

        val request = HttpRequest.newBuilder(URI.create("$AUTH_BASE/token?grant_type=password"))
            .header("apikey", ANON_KEY)
            .header("Content-Type", "application/json")
            .timeout(Duration.ofSeconds(30))
            .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
            .build()

        val response = http.send(request, HttpResponse.BodyHandlers.ofString())
        if (response.statusCode() !in 200..299) {
            throw SnippeterException(describeAuthError(response.statusCode(), response.body()))
        }

        val json = JSONObject(response.body())
        val access = json.optString("access_token", "")
        val refresh = json.optString("refresh_token", "")
        if (access.isBlank()) {
            throw SnippeterException("Sign-in succeeded but no access token was returned.")
        }
        SessionStore.save(access, refresh)
    }

    /**
     * Exchanges the stored refresh token for a fresh session. Returns the new
     * access token, or null if there is no refresh token or the refresh failed.
     */
    private fun refreshSession(): String? {
        val refresh = SessionStore.refreshToken() ?: return null
        val payload = JSONObject().put("refresh_token", refresh).toString()

        val request = HttpRequest.newBuilder(URI.create("$AUTH_BASE/token?grant_type=refresh_token"))
            .header("apikey", ANON_KEY)
            .header("Content-Type", "application/json")
            .timeout(Duration.ofSeconds(30))
            .POST(HttpRequest.BodyPublishers.ofString(payload, StandardCharsets.UTF_8))
            .build()

        val response = http.send(request, HttpResponse.BodyHandlers.ofString())
        if (response.statusCode() !in 200..299) {
            // Refresh token is stale/revoked — drop it so the user is prompted to sign in again.
            SessionStore.clear()
            return null
        }

        val json = JSONObject(response.body())
        val access = json.optString("access_token", "")
        val newRefresh = json.optString("refresh_token", refresh)
        if (access.isBlank()) {
            SessionStore.clear()
            return null
        }
        SessionStore.save(access, newRefresh)
        return access
    }

    // ---------------------------------------------------------------------
    // Reads
    // ---------------------------------------------------------------------

    /** Fetches all of the signed-in user's live snippets, newest first. */
    fun fetchSnippets(): List<Snippet> {
        val query = "select=$SNIPPET_SELECT&deleted_at=is.null&order=updated_at.desc"
        val body = authedGet("$REST_BASE/snippets?$query")
        val array = JSONArray(body)
        val out = ArrayList<Snippet>(array.length())
        for (i in 0 until array.length()) {
            val o = array.getJSONObject(i)
            out.add(
                Snippet(
                    id = o.optString("id", ""),
                    title = o.optString("title", "").ifBlank { "Untitled" },
                    body = o.optString("body", ""),
                    languageId = o.optString("language_id", ""),
                    description = o.optString("description", ""),
                ),
            )
        }
        return out
    }

    /** Fetches the live files for a snippet, ordered by position ascending. */
    fun fetchFiles(snippetId: String): List<SnippetFile> {
        val encodedId = URLEncoder.encode(snippetId, StandardCharsets.UTF_8)
        val query = "select=$FILE_SELECT&snippet_id=eq.$encodedId&deleted_at=is.null&order=position.asc"
        val body = authedGet("$REST_BASE/snippet_files?$query")
        val array = JSONArray(body)
        val out = ArrayList<SnippetFile>(array.length())
        for (i in 0 until array.length()) {
            val o = array.getJSONObject(i)
            out.add(
                SnippetFile(
                    id = o.optString("id", ""),
                    snippetId = o.optString("snippet_id", snippetId),
                    filename = o.optString("filename", "").ifBlank { "file" },
                    languageId = o.optString("language_id", ""),
                    content = o.optString("content", ""),
                    position = o.optInt("position", 0),
                ),
            )
        }
        return out
    }

    // ---------------------------------------------------------------------
    // Writes
    // ---------------------------------------------------------------------

    /**
     * Creates a snippet plus its single mirrored file per the backend contract.
     * The snippet body mirrors the first file's content. owner_id is never sent;
     * the server default + RLS bind it to the signed-in user.
     */
    fun saveSnippet(title: String, content: String, languageId: String) {
        val now = System.currentTimeMillis()
        val snippetId = UUID.randomUUID().toString()
        val fileId = UUID.randomUUID().toString()

        val snippet = JSONObject()
            .put("id", snippetId)
            .put("title", title)
            .put("body", content)
            .put("type", "snippet")
            .put("language_id", languageId)
            .put("visibility", "private")
            .put("is_favorite", false)
            .put("created_at", now)
            .put("updated_at", now)
        authedPost("$REST_BASE/snippets", snippet.toString())

        val file = JSONObject()
            .put("id", fileId)
            .put("snippet_id", snippetId)
            .put("filename", filenameFor(title, languageId))
            .put("language_id", languageId)
            .put("content", content)
            .put("position", 0)
            .put("created_at", now)
            .put("updated_at", now)
        authedPost("$REST_BASE/snippet_files", file.toString())
    }

    // ---------------------------------------------------------------------
    // HTTP plumbing with single-retry token refresh
    // ---------------------------------------------------------------------

    private fun authedGet(url: String): String {
        val attempt: (String) -> HttpResponse<String> = { token ->
            val request = HttpRequest.newBuilder(URI.create(url))
                .header("apikey", ANON_KEY)
                .header("Authorization", "Bearer $token")
                .header("Content-Type", "application/json")
                .timeout(Duration.ofSeconds(30))
                .GET()
                .build()
            http.send(request, HttpResponse.BodyHandlers.ofString())
        }
        return sendWithRefresh(attempt)
    }

    private fun authedPost(url: String, jsonBody: String) {
        val attempt: (String) -> HttpResponse<String> = { token ->
            val request = HttpRequest.newBuilder(URI.create(url))
                .header("apikey", ANON_KEY)
                .header("Authorization", "Bearer $token")
                .header("Content-Type", "application/json")
                .header("Prefer", "return=minimal")
                .timeout(Duration.ofSeconds(30))
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                .build()
            http.send(request, HttpResponse.BodyHandlers.ofString())
        }
        sendWithRefresh(attempt)
    }

    /**
     * Runs [attempt] with the current access token. On a 401, refreshes the
     * session once and retries. Returns the response body on success.
     */
    private fun sendWithRefresh(attempt: (String) -> HttpResponse<String>): String {
        val token = SessionStore.accessToken()
            ?: throw SnippeterException("You are not signed in. Run \"Snippeter: Sign In\" first.")

        var response = attempt(token)
        if (response.statusCode() == 401) {
            val refreshed = refreshSession()
                ?: throw SnippeterException("Your session expired. Please sign in again.")
            response = attempt(refreshed)
        }

        if (response.statusCode() !in 200..299) {
            throw SnippeterException(describeRestError(response.statusCode(), response.body()))
        }
        return response.body()
    }

    // ---------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------

    private fun filenameFor(title: String, languageId: String): String {
        val safe = title.trim()
            .lowercase()
            .replace(Regex("[^a-z0-9._-]+"), "-")
            .trim('-')
            .ifBlank { "snippet" }
        val ext = extensionFor(languageId)
        return if (ext.isBlank()) safe else "$safe.$ext"
    }

    private fun extensionFor(languageId: String): String = when (languageId.lowercase()) {
        "kotlin" -> "kt"
        "java" -> "java"
        "javascript", "js" -> "js"
        "typescript", "ts" -> "ts"
        "typescriptreact", "tsx" -> "tsx"
        "javascriptreact", "jsx" -> "jsx"
        "python" -> "py"
        "ruby" -> "rb"
        "go" -> "go"
        "rust" -> "rs"
        "dart" -> "dart"
        "swift" -> "swift"
        "csharp", "c#" -> "cs"
        "cpp", "c++" -> "cpp"
        "c" -> "c"
        "php" -> "php"
        "html" -> "html"
        "css" -> "css"
        "scss" -> "scss"
        "json" -> "json"
        "yaml", "yml" -> "yaml"
        "markdown", "md" -> "md"
        "sql" -> "sql"
        "shell", "bash", "sh" -> "sh"
        "xml" -> "xml"
        else -> "txt"
    }

    private fun describeAuthError(status: Int, body: String): String {
        val parsed = parseError(body)
        if (parsed != null) return parsed
        return when (status) {
            400 -> "Invalid email or password."
            else -> "Sign-in failed (HTTP $status)."
        }
    }

    private fun describeRestError(status: Int, body: String): String {
        val parsed = parseError(body)
        if (parsed != null) return parsed
        return "Request failed (HTTP $status)."
    }

    /** Best-effort extraction of a human message from a GoTrue/PostgREST error body. */
    private fun parseError(body: String): String? {
        if (body.isBlank()) return null
        return try {
            val o = JSONObject(body)
            when {
                o.has("error_description") -> o.getString("error_description")
                o.has("msg") -> o.getString("msg")
                o.has("message") -> o.getString("message")
                o.has("error") -> o.getString("error")
                else -> null
            }
        } catch (_: Exception) {
            null
        }
    }
}
