# Snippeter for JetBrains

Bring your [Snippeter](https://snippeter.io) library into IntelliJ IDEA and other
JetBrains IDEs. Pull a snippet into the editor at the caret, or push a selection
back to your library — without leaving your code.

Snippeter is a fast, local-first manager for code snippets and AI prompts. This
plugin mirrors the Snippeter VS Code extension's core flow against the same live
backend.

## Features

All three actions live under **Tools → Snippeter**:

- **Sign In** — authenticate with your Snippeter email and password. The session
  (access + refresh tokens) is stored in the IDE's PasswordSafe, so it survives
  restarts and is never written to plain settings.
- **Insert Snippet** — requires an open editor. Fetches your snippets and shows a
  chooser (title · language). On pick, it loads that snippet's files ordered by
  position: one file is used directly, several show a second chooser, and none
  falls back to the snippet body. The content is inserted at the caret inside a
  single undoable write command. Expired access tokens are refreshed once and the
  request is retried automatically.
- **Save Selection as Snippet** — takes the editor selection, or the whole
  document when nothing is selected, prompts for a title (defaulting to the file
  name), and creates a new private snippet plus its mirrored file.

## Prerequisites

- **JDK 17** (the build uses a JVM 17 toolchain).
- A network connection the first time you build (Gradle and the IntelliJ Platform
  artifacts are downloaded by the build).
- A Snippeter account (email + password).

No Gradle install is required on your machine — the wrapper bootstraps Gradle 8.10.

## First-time setup: create the wrapper jar

This project ships `gradle/wrapper/gradle-wrapper.properties` but not the wrapper
jar (binaries are not committed). Generate it once with a locally installed
Gradle:

```bash
gradle wrapper --gradle-version 8.10
```

After that, the `./gradlew` script and `gradle-wrapper.jar` exist and you can use
the wrapper for everything below.

## Build and run

From this directory (`integrations/jetbrains`):

```bash
# Launch a sandbox IDE with the plugin installed (for development/testing):
./gradlew runIde

# Produce a distributable plugin zip in build/distributions/:
./gradlew buildPlugin
```

To install the built plugin into a real IDE: **Settings → Plugins → ⚙ → Install
Plugin from Disk…** and pick the zip from `build/distributions/`.

## How it works

- HTTP is done with the JDK's `java.net.http.HttpClient`; JSON is parsed with
  `org.json`. There is no `supabase-js` dependency — this is the JVM.
- Auth uses Supabase GoTrue's email + password grant. The publishable (anon) key
  is embedded in the client, which is safe by design; row-level security scopes
  every row to the signed-in user and their team workspaces.
- Creating a snippet writes a `snippets` row whose `body` mirrors the first
  file's content, then a `snippet_files` row at `position: 0`. `owner_id` is never
  sent on insert — the server default plus RLS bind it to you.

## Project layout

```
build.gradle.kts                Gradle Kotlin DSL build (IntelliJ Platform plugin v2)
settings.gradle.kts             Project + plugin/dependency repositories
gradle.properties               Build flags
gradle/wrapper/...              Wrapper config (jar created by `gradle wrapper`)
src/main/kotlin/io/snippeter/jetbrains/
  SnippeterClient.kt            PostgREST + GoTrue client with token refresh
  SessionStore.kt               PasswordSafe-backed token storage
  Notifications.kt              Balloon helper
  ui/SignInDialog.kt            Email/password DialogWrapper
  actions/SignInAction.kt       Tools → Snippeter → Sign In
  actions/InsertSnippetAction.kt   Tools → Snippeter → Insert Snippet
  actions/SaveSelectionAction.kt   Tools → Snippeter → Save Selection as Snippet
src/main/resources/META-INF/plugin.xml   Plugin manifest (actions, group, vendor)
```
