type QA = {
  question: string;
  answer: string;
};

const faqs: QA[] = [
  {
    question: "Which platforms does Snippeter run on?",
    answer:
      "All six: Windows, Linux, macOS, iOS and Android as native apps, plus a full web app in any modern browser. It is one Flutter codebase, so the library, keyboard shortcuts and search behave identically everywhere — start a snippet on your laptop and finish it on your phone.",
  },
  {
    question: "What does “local-first” actually mean for my privacy?",
    answer:
      "Your snippets are stored on your device in a local SQLite database and the entire app — including FTS5 search and code-to-image export — works with no network connection. Nothing leaves your machine unless you turn on sync, and when you do, your data is encrypted in transit and isolated to your account with row-level security. End-to-end encryption is on our roadmap.",
  },
  {
    question: "How do shared team workspaces work?",
    answer:
      "Team workspaces are backed by row-level security (RLS), so each member only ever sees the collections, tags and AI-prompt libraries they’ve been granted. Admins manage role-based access and seat billing centrally; SSO/SAML and an audit log are on the Team roadmap. Billing is per seat from the first user — there’s no 5-seat minimum.",
  },
  {
    question: "Can I export my data, or am I locked in?",
    answer:
      "No lock-in. Everything lives in an open local SQLite database, and you can import or export via GitHub Gist at any time, plus export snippets as PNG or SVG images. Cancel a paid plan and the free local-first app — and all your local snippets — keep working exactly as before.",
  },
  {
    question: "What’s the difference between the Free and Pro plans?",
    answer:
      "Free is the complete local-first app on every platform, with unlimited local snippets and up to 50 cloud-synced snippets on a single device. Pro unlocks unlimited sync across all your devices, unlimited cloud storage, snippet version history, and the full AI-prompt tooling — variables, metadata and templated fields.",
  },
  {
    question: "Do the AI-prompt features lock me to one model?",
    answer:
      "No. Snippeter stores prompts with typed {{variables}} and metadata, then produces finished text you can paste into any model or tool — ChatGPT, Claude, a local LLM, your own API. It’s a prompt library, not a model wrapper, so you stay in control of where prompts run.",
  },
];

export default function Faq() {
  return (
    <section className="border-t border-hairline/60 py-20 sm:py-24">
      <div className="mx-auto max-w-3xl px-4 sm:px-6">
        <div className="text-center">
          <p className="text-sm font-medium uppercase tracking-wider text-accent">
            FAQ
          </p>
          <h2 className="mt-3 text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
            Questions, answered
          </h2>
        </div>

        <div className="mt-12 divide-y divide-hairline">
          {faqs.map((faq) => (
            <details
              key={faq.question}
              className="group py-5 [&_summary::-webkit-details-marker]:hidden"
            >
              <summary className="flex cursor-pointer items-center justify-between gap-4 rounded-lg text-left text-base font-medium text-ink">
                <span>{faq.question}</span>
                <span
                  className="flex h-7 w-7 shrink-0 items-center justify-center rounded-full border border-hairline text-muted transition-transform duration-200 group-open:rotate-45 group-open:border-accent/50 group-open:text-accent"
                  aria-hidden
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                    <path
                      d="M12 5v14M5 12h14"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                    />
                  </svg>
                </span>
              </summary>
              <div className="mt-3 pr-10 text-sm leading-relaxed text-muted">
                {faq.answer}
              </div>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}
