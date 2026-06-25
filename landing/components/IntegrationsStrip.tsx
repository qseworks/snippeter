import type { ReactNode } from "react";

type Integration = {
  name: string;
  blurb: string;
  icon: ReactNode;
};

const integrations: Integration[] = [
  {
    name: "VS Code",
    blurb: "Insert & save from the command palette",
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
        <path
          d="M17 2 7.5 11 4 8 2 9l3 3-3 3 2 1 3.5-3L17 22l5-2V4z"
          fill="currentColor"
          opacity="0.92"
        />
        <path d="M17 7.2 11.5 12 17 16.8z" fill="#0F1115" />
      </svg>
    ),
  },
  {
    name: "JetBrains",
    blurb: "Live templates in every IDE",
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
        <rect
          x="3"
          y="3"
          width="18"
          height="18"
          rx="3"
          stroke="currentColor"
          strokeWidth="1.8"
        />
        <path
          d="M6 17.5h6"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
        <path
          d="m8 7 2 2-2 2"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  {
    name: "Chrome",
    blurb: "Clip & paste anywhere on the web",
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
        <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.8" />
        <circle cx="12" cy="12" r="3.2" stroke="currentColor" strokeWidth="1.8" />
        <path
          d="M12 8.8h8M9.2 13.5 5.2 6.8M14.8 13.5l-4 6.7"
          stroke="currentColor"
          strokeWidth="1.6"
          strokeLinecap="round"
        />
      </svg>
    ),
  },
  {
    name: "CLI",
    blurb: "Pipe snippets straight to stdout",
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
        <rect
          x="3"
          y="4"
          width="18"
          height="16"
          rx="2"
          stroke="currentColor"
          strokeWidth="1.8"
        />
        <path
          d="m7 9 3 3-3 3m5 0h4"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  {
    name: "Web",
    blurb: "The full app in any browser",
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" aria-hidden>
        <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.8" />
        <path
          d="M3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18"
          stroke="currentColor"
          strokeWidth="1.6"
        />
      </svg>
    ),
  },
];

export default function IntegrationsStrip() {
  return (
    <section
      id="integrations"
      className="scroll-mt-20 border-y border-hairline/60 bg-surface/40 py-16"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="flex flex-col items-start justify-between gap-3 sm:flex-row sm:items-end">
          <div>
            <p className="text-sm font-medium uppercase tracking-wider text-accent">
              Integrations
            </p>
            <h2 className="mt-3 text-2xl font-semibold tracking-tight sm:text-3xl">
              First-party integrations, not afterthoughts
            </h2>
          </div>
          <p className="max-w-sm text-sm text-muted">
            Reach your library from the tools you already live in. Same snippets,
            same search, wherever you are.
          </p>
        </div>

        <ul className="mt-10 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
          {integrations.map((item) => (
            <li
              key={item.name}
              className="group flex flex-col gap-3 rounded-2xl border border-hairline bg-surface p-5 transition-all duration-200 hover:-translate-y-0.5 hover:border-accent/40 hover:bg-surface-elevated"
            >
              <span className="flex h-11 w-11 items-center justify-center rounded-xl border border-hairline bg-surface-elevated text-ink transition-colors group-hover:text-accent">
                {item.icon}
              </span>
              <span className="font-medium">{item.name}</span>
              <span className="text-xs leading-relaxed text-muted">
                {item.blurb}
              </span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
