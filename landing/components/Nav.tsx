import Logo from "./Logo";
import CtaButton from "./CtaButton";

const links = [
  { label: "Features", href: "#features" },
  { label: "Integrations", href: "#integrations" },
  { label: "Pricing", href: "#pricing" },
  { label: "GitHub", href: "https://github.com/snippeter", external: true },
];

export default function Nav() {
  return (
    <header className="sticky top-0 z-50 border-b border-hairline/70 bg-bg/70 backdrop-blur-xl">
      <nav
        aria-label="Primary"
        className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6"
      >
        <a href="#top" className="inline-flex rounded-lg">
          <Logo size={30} idSuffix="nav" />
        </a>

        <ul className="hidden items-center gap-1 md:flex">
          {links.map((link) => (
            <li key={link.label}>
              <a
                href={link.href}
                {...(link.external
                  ? { target: "_blank", rel: "noopener noreferrer" }
                  : {})}
                className="rounded-lg px-3 py-2 text-sm text-muted transition-colors hover:text-ink"
              >
                {link.label}
              </a>
            </li>
          ))}
        </ul>

        <div className="flex items-center gap-3">
          {/*
            "Open Snippeter" launches the deployed web app.
            Replace "#" with the production web-app URL (e.g. https://app.snippeter.app)
            once it is live.
          */}
          <CtaButton href="#" size="md" className="shadow-none sm:shadow">
            Open Snippeter
          </CtaButton>
        </div>
      </nav>
    </header>
  );
}
