// Snippeter background service worker (MV3).
// - Registers a "Save selection to Snippeter" context menu.
// - On click, saves the selected text as a new snippet via the REST client.
// - Surfaces success/failure through a notification and the action badge.

import { createSnippet, isSignedIn } from "./lib/api.js";

const MENU_ID = "snippeter-save-selection";

// ---------------------------------------------------------------------------
// Install / menu setup
// ---------------------------------------------------------------------------

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.removeAll(() => {
    chrome.contextMenus.create({
      id: MENU_ID,
      title: "Save selection to Snippeter",
      contexts: ["selection"],
    });
  });
});

// Service workers can be torn down; re-assert the menu on startup too.
chrome.runtime.onStartup.addListener(() => {
  chrome.contextMenus.create(
    {
      id: MENU_ID,
      title: "Save selection to Snippeter",
      contexts: ["selection"],
    },
    () => void chrome.runtime.lastError // ignore "duplicate id" on re-create
  );
});

// ---------------------------------------------------------------------------
// Context menu click → create snippet
// ---------------------------------------------------------------------------

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId !== MENU_ID) return;

  const selection = (info.selectionText || "").trim();
  if (!selection) {
    await notify("Nothing to save", "No text was selected.");
    return;
  }

  // If signed out, store nothing and prompt the user to sign in via the popup.
  if (!(await isSignedIn())) {
    await flashBadge("!", "#E5C07B");
    await notify(
      "Sign in to Snippeter",
      "Open the Snippeter popup and sign in, then try again."
    );
    // Best-effort: open the popup so the user can sign in immediately.
    try {
      await chrome.action.openPopup();
    } catch (_) {
      // openPopup may be unavailable depending on context — non-fatal.
    }
    return;
  }

  const title = deriveTitle(tab, selection);
  const languageId = guessLanguage(tab?.url, selection);

  try {
    await createSnippet({
      title,
      content: selection,
      languageId,
      description: tab?.url ? `Saved from ${tab.url}` : "Saved from Chrome",
    });
    await flashBadge("OK", "#65EA92");
    await notify("Saved to Snippeter", truncate(title, 80));
  } catch (err) {
    await flashBadge("ERR", "#E06C75");
    await notify(
      "Couldn't save snippet",
      (err && err.message) || "Unexpected error. Try again."
    );
  }
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function deriveTitle(tab, selection) {
  const tabTitle = (tab && tab.title && tab.title.trim()) || "";
  if (tabTitle) return truncate(tabTitle, 120);
  // Fall back to the first non-empty line of the selection.
  const firstLine = selection.split(/\r?\n/).find((l) => l.trim().length > 0);
  return truncate((firstLine || "Untitled snippet").trim(), 120);
}

function guessLanguage(url, text) {
  const u = (url || "").toLowerCase();
  if (u.includes("github.com") || u.includes("gitlab.com")) {
    if (u.endsWith(".ts") || u.endsWith(".tsx")) return "typescript";
    if (u.endsWith(".js") || u.endsWith(".jsx")) return "javascript";
    if (u.endsWith(".py")) return "python";
    if (u.endsWith(".dart")) return "dart";
    if (u.endsWith(".go")) return "go";
    if (u.endsWith(".rs")) return "rust";
  }
  // Lightweight content sniffing.
  const t = text.slice(0, 400);
  if (/^\s*</.test(t) && /<\/[a-z]+>/i.test(t)) return "html";
  if (/^\s*[{[]/.test(t) && /["']\s*:\s*/.test(t)) return "json";
  if (/\bdef\s+\w+\s*\(|\bimport\s+\w+/.test(t) && /:\s*$/m.test(t))
    return "python";
  if (/\bfunction\b|=>|\bconst\b|\blet\b/.test(t)) return "javascript";
  return "plaintext";
}

function truncate(s, max) {
  if (!s) return s;
  return s.length > max ? s.slice(0, max - 1).trimEnd() + "…" : s;
}

async function notify(title, message) {
  try {
    await chrome.notifications.create({
      type: "basic",
      iconUrl: "icons/icon128.png",
      title,
      message: message || "",
      priority: 0,
    });
  } catch (_) {
    // notifications may be unavailable on some platforms; the badge still
    // conveys status, so this is non-fatal.
  }
}

async function flashBadge(text, color) {
  try {
    await chrome.action.setBadgeBackgroundColor({ color });
    await chrome.action.setBadgeText({ text });
    setTimeout(() => {
      chrome.action.setBadgeText({ text: "" });
    }, 3500);
  } catch (_) {
    // Badge APIs are best-effort.
  }
}
