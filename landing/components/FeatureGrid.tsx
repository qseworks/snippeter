import type { ReactNode } from "react";

type Feature = {
  title: string;
  description: string;
  icon: ReactNode;
};

const iconProps = {
  width: 22,
  height: 22,
  viewBox: "0 0 24 24",
  fill: "none",
  strokeWidth: 1.8,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
  stroke: "currentColor",
};

const features: Feature[] = [
  {
    title: "Full-text search",
    description:
      "SQLite FTS5 indexes every snippet, tag and field on-device. Results land as you type — across thousands of entries, with zero network round-trips.",
    icon: (
      <svg {...iconProps}>
        <circle cx="11" cy="11" r="7" />
        <path d="m20 20-3.5-3.5" />
      </svg>
    ),
  },
  {
    title: "Code → image export",
    description:
      "Turn any snippet into a clean, carbon-style PNG or SVG. Pick a theme, frame and padding, then share a polished image straight to a PR, doc or thread.",
    icon: (
      <svg {...iconProps}>
        <rect x="3" y="4" width="18" height="16" rx="2" />
        <circle cx="8.5" cy="9.5" r="1.5" />
        <path d="m3 16 5-4 4 3 3-2 6 5" />
      </svg>
    ),
  },
  {
    title: "AI prompts with {{variables}}",
    description:
      "Store reusable prompts with typed {{variables}} and metadata. Fill the blanks at run time and paste a finished prompt into any model — no copy-paste archaeology.",
    icon: (
      <svg {...iconProps}>
        <path d="M12 3v3m0 12v3m9-9h-3M6 12H3m13.5-6.5L14 8m-4 8-2.5 2.5m9 0L14 16m-4-8L7.5 5.5" />
        <circle cx="12" cy="12" r="3.2" />
      </svg>
    ),
  },
  {
    title: "Collections + tags",
    description:
      "Organize work the way you think: nestable collections plus free-form tags. Filter by both at once to surface exactly the snippet you need in seconds.",
    icon: (
      <svg {...iconProps}>
        <path d="M3 7a2 2 0 0 1 2-2h4l2 2h6a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
        <path d="M14.5 12.5h.01" />
      </svg>
    ),
  },
  {
    title: "Cross-platform",
    description:
      "One Flutter codebase, six native apps — Windows, Linux, macOS, iOS and Android — plus the web. The same library, identical shortcuts, on every machine you touch.",
    icon: (
      <svg {...iconProps}>
        <rect x="2" y="4" width="20" height="13" rx="2" />
        <path d="M8 21h8m-4-4v4" />
      </svg>
    ),
  },
  {
    title: "Local-first & offline",
    description:
      "Your snippets live on your device, not someone's server. Everything works fully offline; opt into end-to-end encrypted sync only when you want it across devices.",
    icon: (
      <svg {...iconProps}>
        <path d="M12 3 4 6v6c0 5 3.4 7.7 8 9 4.6-1.3 8-4 8-9V6z" />
        <path d="m9 12 2 2 4-4" />
      </svg>
    ),
  },
];

function FeatureCard({ title, description, icon }: Feature) {
  return (
    <article className="group relative rounded-2xl border border-hairline bg-surface p-6 transition-all duration-200 hover:-translate-y-0.5 hover:border-accent/40 hover:bg-surface-elevated">
      <div className="flex h-11 w-11 items-center justify-center rounded-xl border border-hairline bg-surface-elevated text-accent transition-colors group-hover:border-accent/40">
        {icon}
      </div>
      <h3 className="mt-5 text-lg font-semibold tracking-tight">{title}</h3>
      <p className="mt-2 text-sm leading-relaxed text-muted">{description}</p>
    </article>
  );
}

export default function FeatureGrid() {
  return (
    <section id="features" className="scroll-mt-20 py-20 sm:py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="max-w-2xl">
          <p className="text-sm font-medium uppercase tracking-wider text-accent">
            Features
          </p>
          <h2 className="mt-3 text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
            Everything a snippet manager should be — and the AI-prompt tooling it
            was missing.
          </h2>
          <p className="mt-4 text-pretty text-muted">
            Built for developers who keep a growing library of code and prompts.
            Fast where it counts, private by default, and consistent on every
            device.
          </p>
        </div>

        <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => (
            <FeatureCard key={feature.title} {...feature} />
          ))}
        </div>
      </div>
    </section>
  );
}
