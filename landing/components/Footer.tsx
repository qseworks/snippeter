import Logo from "./Logo";

const columns: { heading: string; links: { label: string; href: string; external?: boolean }[] }[] =
  [
    {
      heading: "Product",
      links: [
        { label: "Features", href: "#features" },
        { label: "Integrations", href: "#integrations" },
        { label: "Pricing", href: "#pricing" },
        { label: "Open Snippeter", href: "#" }, // → deployed web app
      ],
    },
    {
      heading: "Platforms",
      links: [
        { label: "macOS", href: "#" },
        { label: "Windows", href: "#" },
        { label: "Linux", href: "#" },
        { label: "iOS & Android", href: "#" },
      ],
    },
    {
      heading: "Resources",
      links: [
        {
          label: "GitHub",
          href: "https://github.com/snippeter",
          external: true,
        },
        { label: "Documentation", href: "#" },
        { label: "Changelog", href: "#" },
        { label: "Status", href: "#" },
      ],
    },
  ];

export default function Footer() {
  return (
    <footer className="border-t border-hairline bg-surface/40">
      <div className="mx-auto max-w-6xl px-4 py-14 sm:px-6">
        <div className="grid gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div className="lg:col-span-1">
            <a href="#top" className="inline-flex rounded-lg">
              <Logo size={30} idSuffix="footer" />
            </a>
            <p className="mt-4 max-w-xs text-sm leading-relaxed text-muted">
              A fast, local-first manager for code snippets and AI prompts.
              Everywhere you code.
            </p>
          </div>

          {columns.map((column) => (
            <nav key={column.heading} aria-label={column.heading}>
              <h2 className="text-sm font-semibold tracking-tight text-ink">
                {column.heading}
              </h2>
              <ul className="mt-4 space-y-2.5">
                {column.links.map((link) => (
                  <li key={link.label}>
                    <a
                      href={link.href}
                      {...(link.external
                        ? { target: "_blank", rel: "noopener noreferrer" }
                        : {})}
                      className="text-sm text-muted transition-colors hover:text-ink"
                    >
                      {link.label}
                    </a>
                  </li>
                ))}
              </ul>
            </nav>
          ))}
        </div>

        <div className="mt-12 flex flex-col items-start justify-between gap-4 border-t border-hairline pt-8 text-sm text-muted sm:flex-row sm:items-center">
          <p>© 2026 Snippeter. All rights reserved.</p>
          <p className="flex flex-wrap items-center gap-x-4 gap-y-1">
            <span className="inline-flex items-center gap-1.5">
              <span className="h-1.5 w-1.5 rounded-full bg-accent" />
              Local-first by design
            </span>
            <a href="#" className="hover:text-ink">
              Privacy
            </a>
            <a href="#" className="hover:text-ink">
              Terms
            </a>
          </p>
        </div>
      </div>
    </footer>
  );
}
