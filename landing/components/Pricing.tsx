import CtaButton from "./CtaButton";

type Tier = {
  name: string;
  tagline: string;
  priceMonthlyUsd: number;
  priceAnnualUsd: number | null;
  unit: string;
  features: string[];
  cta: string;
  highlighted: boolean;
};

const tiers: Tier[] = [
  {
    name: "Free",
    tagline:
      "The full local-first app, free forever — your snippets live on your device.",
    priceMonthlyUsd: 0,
    priceAnnualUsd: null,
    unit: "forever",
    features: [
      "All 6 native apps + web, fully offline — Windows, Linux, macOS, iOS, Android",
      "Unlimited local snippets, nestable collections & tags",
      "FTS5 full-text search across everything on-device",
      "Carbon-style code-to-image export (PNG/SVG)",
      "VS Code, JetBrains, Chrome & CLI integrations",
      "GitHub Gist import/export",
      "Up to 50 cloud-synced snippets on one device",
    ],
    cta: "Download free",
    highlighted: false,
  },
  {
    name: "Pro",
    tagline:
      "Unlimited sync across every device, plus first-class AI-prompt tooling.",
    priceMonthlyUsd: 9,
    priceAnnualUsd: 84,
    unit: "per month",
    features: [
      "Everything in Free",
      "Unlimited end-to-end encrypted cloud sync across all your devices",
      "Unlimited cloud snippets, collections & version history",
      "AI-prompt variables, metadata & templated fields",
      "Smart language auto-detection (600+ languages)",
      "Custom export themes & shareable image links",
      "Priority email support",
    ],
    cta: "Start 14-day trial",
    highlighted: true,
  },
  {
    name: "Team",
    tagline:
      "Shared workspaces with row-level security and admin controls — priced per seat, no 5-seat minimum.",
    priceMonthlyUsd: 8,
    priceAnnualUsd: 72,
    unit: "per user / month",
    features: [
      "Everything in Pro for every member",
      "Shared team workspaces backed by row-level security (RLS)",
      "Role-based access & centralized seat billing",
      "Shared collections, tags & AI-prompt libraries",
      "SSO / SAML and audit log",
      "Per-seat pricing from seat one — no 5-seat block",
      "Priority support with onboarding",
    ],
    cta: "Start team trial",
    highlighted: false,
  },
];

/** Format the headline price; null => "Free". */
function formatPrice(tier: Tier) {
  if (tier.priceMonthlyUsd === 0) return "Free";
  return `$${tier.priceMonthlyUsd}`;
}

/** Annual-savings note when an annual price is available. */
function annualNote(tier: Tier): string | null {
  if (tier.priceAnnualUsd == null) return null;
  const monthlyEquivalent = tier.priceAnnualUsd / 12;
  const fullYearAtMonthly = tier.priceMonthlyUsd * 12;
  const saved = fullYearAtMonthly - tier.priceAnnualUsd;
  // Trim a trailing .0 (e.g. 7.0 -> 7) but keep cents when present.
  const perMonth = Number.isInteger(monthlyEquivalent)
    ? `${monthlyEquivalent}`
    : monthlyEquivalent.toFixed(2);
  return `or $${tier.priceAnnualUsd}/yr — $${perMonth}/mo billed annually, save $${saved}`;
}

function CheckIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      className="mt-0.5 shrink-0 text-accent"
      aria-hidden
    >
      <path
        d="m5 12.5 4 4 10-11"
        stroke="currentColor"
        strokeWidth="2.2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function PricingCard({ tier }: { tier: Tier }) {
  const note = annualNote(tier);
  return (
    <div
      className={`relative flex flex-col rounded-2xl border p-7 transition-all duration-200 ${
        tier.highlighted
          ? "border-accent/50 bg-surface-elevated shadow-glow"
          : "border-hairline bg-surface hover:border-accent/30"
      }`}
    >
      {tier.highlighted && (
        <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-brand-gradient px-3 py-1 text-xs font-semibold text-bg">
          Most popular
        </span>
      )}

      <h3 className="text-lg font-semibold tracking-tight">{tier.name}</h3>

      <div className="mt-4 flex items-baseline gap-1.5">
        <span className="text-4xl font-semibold tracking-tight">
          {formatPrice(tier)}
        </span>
        {tier.priceMonthlyUsd > 0 && (
          <span className="text-sm text-muted">/ {tier.unit}</span>
        )}
        {tier.priceMonthlyUsd === 0 && (
          <span className="text-sm text-muted">· {tier.unit}</span>
        )}
      </div>

      {note ? (
        <p className="mt-1.5 text-xs font-medium text-accent">{note}</p>
      ) : (
        <p className="mt-1.5 text-xs text-muted">No credit card required</p>
      )}

      <p className="mt-4 min-h-[3rem] text-sm leading-relaxed text-muted">
        {tier.tagline}
      </p>

      <CtaButton
        href="#"
        variant={tier.highlighted ? "primary" : "secondary"}
        size="lg"
        className="mt-5 w-full"
      >
        {tier.cta}
      </CtaButton>

      <ul className="mt-7 space-y-3 border-t border-hairline pt-6 text-sm">
        {tier.features.map((feature) => (
          <li key={feature} className="flex items-start gap-2.5">
            <CheckIcon />
            <span className="text-muted">{feature}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default function Pricing() {
  return (
    <section id="pricing" className="scroll-mt-20 py-20 sm:py-24">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <div className="mx-auto max-w-2xl text-center">
          <p className="text-sm font-medium uppercase tracking-wider text-accent">
            Pricing
          </p>
          <h2 className="mt-3 text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
            Free where it should be. Fair where it counts.
          </h2>
          <p className="mt-4 text-pretty text-muted">
            The local-first app is free forever — you only pay for cross-device
            sync, unlimited cloud storage and AI-prompt tooling. Cancel anytime.
          </p>
        </div>

        <div className="mt-14 grid items-start gap-5 lg:grid-cols-3">
          {tiers.map((tier) => (
            <PricingCard key={tier.name} tier={tier} />
          ))}
        </div>

        <p className="mx-auto mt-8 max-w-2xl text-center text-xs text-muted">
          Prices in USD. Pro and Team include a free trial — no charge until it
          ends. Team is billed per seat from your very first user, with no
          5-seat minimum.
        </p>
      </div>
    </section>
  );
}
