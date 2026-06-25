// Snippeter popup controller.
// Wires the sign-in form, the snippet list, copy-to-clipboard, and
// insert-into-page (via chrome.scripting) against lib/api.js.

import {
  signInWithPassword,
  signOut,
  isSignedIn,
  getSnippets,
  getSnippetFiles,
  ApiError,
} from "./lib/api.js";

// ---------------------------------------------------------------------------
// Element refs
// ---------------------------------------------------------------------------

const els = {
  authView: document.getElementById("authView"),
  listView: document.getElementById("listView"),
  signInForm: document.getElementById("signInForm"),
  email: document.getElementById("email"),
  password: document.getElementById("password"),
  signInBtn: document.getElementById("signInBtn"),
  authError: document.getElementById("authError"),
  signOutBtn: document.getElementById("signOutBtn"),
  search: document.getElementById("search"),
  refreshBtn: document.getElementById("refreshBtn"),
  status: document.getElementById("status"),
  snippetList: document.getElementById("snippetList"),
  emptyState: document.getElementById("emptyState"),
  toast: document.getElementById("toast"),
};

// In-memory snippet cache (full rows from getSnippets).
let allSnippets = [];
// Cache of resolved snippet content keyed by snippet id.
const contentCache = new Map();

// ---------------------------------------------------------------------------
// Boot
// ---------------------------------------------------------------------------

document.addEventListener("DOMContentLoaded", init);

async function init() {
  els.signInForm.addEventListener("submit", onSignIn);
  els.signOutBtn.addEventListener("click", onSignOut);
  els.refreshBtn.addEventListener("click", () => loadSnippets(true));
  els.search.addEventListener("input", renderList);

  if (await isSignedIn()) {
    showSignedIn();
    await loadSnippets();
  } else {
    showSignedOut();
  }
}

// ---------------------------------------------------------------------------
// View switching
// ---------------------------------------------------------------------------

function showSignedOut() {
  els.authView.hidden = false;
  els.listView.hidden = true;
  els.signOutBtn.hidden = true;
  els.authError.hidden = true;
  els.email.focus();
}

function showSignedIn() {
  els.authView.hidden = true;
  els.listView.hidden = false;
  els.signOutBtn.hidden = false;
  els.search.focus();
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

async function onSignIn(event) {
  event.preventDefault();
  const email = els.email.value.trim();
  const password = els.password.value;
  if (!email || !password) return;

  setBusy(true);
  hideAuthError();
  try {
    await signInWithPassword(email, password);
    els.password.value = "";
    showSignedIn();
    await loadSnippets();
  } catch (err) {
    showAuthError(
      err instanceof ApiError
        ? err.message
        : "Sign in failed. Check your connection and try again."
    );
  } finally {
    setBusy(false);
  }
}

async function onSignOut() {
  await signOut();
  allSnippets = [];
  contentCache.clear();
  els.snippetList.innerHTML = "";
  els.search.value = "";
  showSignedOut();
}

function setBusy(busy) {
  els.signInBtn.disabled = busy;
  els.signInBtn.textContent = busy ? "Signing in…" : "Sign in";
}

function showAuthError(msg) {
  els.authError.textContent = msg;
  els.authError.hidden = false;
}

function hideAuthError() {
  els.authError.hidden = true;
}

// ---------------------------------------------------------------------------
// Snippets
// ---------------------------------------------------------------------------

async function loadSnippets(force = false) {
  setStatus("Loading snippets…");
  try {
    allSnippets = await getSnippets();
    if (force) contentCache.clear();
    setStatus(null);
    renderList();
  } catch (err) {
    if (err instanceof ApiError && err.status === 401) {
      // Session unrecoverable — bounce to sign-in.
      showSignedOut();
      return;
    }
    setStatus(
      (err && err.message) || "Couldn't load snippets.",
      true
    );
  }
}

function renderList() {
  const q = els.search.value.trim().toLowerCase();
  const items = q
    ? allSnippets.filter((s) => {
        return (
          (s.title || "").toLowerCase().includes(q) ||
          (s.language_id || "").toLowerCase().includes(q) ||
          (s.description || "").toLowerCase().includes(q) ||
          (s.body || "").toLowerCase().includes(q)
        );
      })
    : allSnippets;

  els.snippetList.innerHTML = "";

  if (allSnippets.length === 0) {
    els.emptyState.hidden = false;
    return;
  }
  els.emptyState.hidden = true;

  if (items.length === 0) {
    setStatus(`No matches for “${els.search.value.trim()}”.`);
    return;
  }
  setStatus(null);

  const frag = document.createDocumentFragment();
  for (const snippet of items) {
    frag.appendChild(renderItem(snippet));
  }
  els.snippetList.appendChild(frag);
}

function renderItem(snippet) {
  const li = document.createElement("li");
  li.className = "snippet-item";

  const top = document.createElement("div");
  top.className = "snippet-top";

  const title = document.createElement("span");
  title.className = "snippet-title";
  title.textContent = snippet.title || "Untitled snippet";
  title.tabIndex = 0;
  title.setAttribute("role", "button");
  title.title = "Copy to clipboard";
  title.addEventListener("click", () => copySnippet(snippet, title));
  title.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      copySnippet(snippet, title);
    }
  });

  const lang = document.createElement("span");
  lang.className = "lang-tag";
  lang.textContent = snippet.language_id || "text";

  top.appendChild(title);
  top.appendChild(lang);
  li.appendChild(top);

  if (snippet.description) {
    const desc = document.createElement("p");
    desc.className = "snippet-desc";
    desc.textContent = snippet.description;
    li.appendChild(desc);
  }

  const actions = document.createElement("div");
  actions.className = "snippet-actions";

  const copyBtn = document.createElement("button");
  copyBtn.type = "button";
  copyBtn.className = "ghost-btn";
  copyBtn.textContent = "Copy";
  copyBtn.addEventListener("click", () => copySnippet(snippet, copyBtn));

  const insertBtn = document.createElement("button");
  insertBtn.type = "button";
  insertBtn.className = "ghost-btn";
  insertBtn.textContent = "Insert into page";
  insertBtn.addEventListener("click", () => insertSnippet(snippet, insertBtn));

  actions.appendChild(copyBtn);
  actions.appendChild(insertBtn);
  li.appendChild(actions);

  return li;
}

/**
 * Resolves a snippet's content: first file's content if present, else body.
 * Caches the result so repeated copies don't refetch.
 */
async function resolveContent(snippet) {
  if (contentCache.has(snippet.id)) {
    return contentCache.get(snippet.id);
  }
  let content = snippet.body || "";
  try {
    const files = await getSnippetFiles(snippet.id);
    if (files && files.length > 0 && typeof files[0].content === "string") {
      content = files[0].content;
    }
  } catch (_) {
    // Fall back to body if file fetch fails.
  }
  contentCache.set(snippet.id, content);
  return content;
}

// ---------------------------------------------------------------------------
// Copy
// ---------------------------------------------------------------------------

async function copySnippet(snippet, flashEl) {
  try {
    const content = await resolveContent(snippet);
    await navigator.clipboard.writeText(content);
    flash(flashEl, "Copied");
    toast("Copied to clipboard");
  } catch (err) {
    toast("Copy failed", true);
  }
}

// ---------------------------------------------------------------------------
// Insert into page
// ---------------------------------------------------------------------------

async function insertSnippet(snippet, flashEl) {
  let content;
  try {
    content = await resolveContent(snippet);
  } catch (_) {
    toast("Couldn't load snippet", true);
    return;
  }

  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (!tab || !tab.id) {
    toast("No active tab", true);
    return;
  }
  if (/^(chrome|edge|about|chrome-extension):/i.test(tab.url || "")) {
    toast("Can't insert on this page", true);
    return;
  }

  try {
    const [result] = await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: insertIntoActiveElement,
      args: [content],
    });
    if (result && result.result === true) {
      flash(flashEl, "Inserted");
      toast("Inserted into page");
    } else {
      toast("No editable field focused", true);
    }
  } catch (err) {
    toast("Insert failed on this page", true);
  }
}

/**
 * Injected into the page. Inserts `text` at the caret of the focused input/
 * textarea/contenteditable. Returns true on success.
 *
 * This function is serialized and runs in the page context — it must be
 * self-contained (no closures over popup scope).
 */
function insertIntoActiveElement(text) {
  const el = document.activeElement;
  if (!el) return false;

  const tag = el.tagName ? el.tagName.toLowerCase() : "";
  const isTextInput =
    tag === "textarea" ||
    (tag === "input" &&
      /^(text|search|url|tel|email|password|number|)$/i.test(el.type || ""));

  if (isTextInput) {
    const start = el.selectionStart ?? el.value.length;
    const end = el.selectionEnd ?? el.value.length;
    const before = el.value.slice(0, start);
    const after = el.value.slice(end);
    el.value = before + text + after;
    const caret = start + text.length;
    try {
      el.setSelectionRange(caret, caret);
    } catch (_) {
      /* some input types don't support selection */
    }
    el.dispatchEvent(new Event("input", { bubbles: true }));
    el.dispatchEvent(new Event("change", { bubbles: true }));
    return true;
  }

  if (el.isContentEditable) {
    el.focus();
    let ok = false;
    try {
      ok = document.execCommand("insertText", false, text);
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      // Fallback: append at the end of the editable region.
      const sel = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(el);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
      range.insertNode(document.createTextNode(text));
      el.dispatchEvent(new Event("input", { bubbles: true }));
    }
    return true;
  }

  return false;
}

// ---------------------------------------------------------------------------
// UI feedback
// ---------------------------------------------------------------------------

function flash(el, label) {
  if (!el) return;
  const original = el.textContent;
  el.textContent = label;
  el.classList.add("is-flash");
  setTimeout(() => {
    el.textContent = original;
    el.classList.remove("is-flash");
  }, 1100);
}

let toastTimer = null;
function toast(message, isError = false) {
  els.toast.textContent = message;
  els.toast.classList.toggle("is-error", isError);
  els.toast.hidden = false;
  // Force reflow so the transition runs even on rapid re-toasts.
  void els.toast.offsetWidth;
  els.toast.classList.add("is-visible");
  if (toastTimer) clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    els.toast.classList.remove("is-visible");
    setTimeout(() => {
      els.toast.hidden = true;
    }, 200);
  }, 1600);
}

function setStatus(message, isError = false) {
  if (!message) {
    els.status.hidden = true;
    els.status.textContent = "";
    els.status.classList.remove("is-error");
    return;
  }
  els.status.textContent = message;
  els.status.classList.toggle("is-error", isError);
  els.status.hidden = false;
}
