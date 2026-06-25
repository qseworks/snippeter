import CtaButton from "./CtaButton";

/** A traffic-light window header used by the faux app mock. */
function WindowDots() {
  return (
    <div className="flex items-center gap-1.5" aria-hidden="true">
      <span className="h-3 w-3 rounded-full bg-[#ff5f57]" />
      <span className="h-3 w-3 rounded-full bg-[#febc2e]" />
      <span className="h-3 w-3 rounded-full bg-[#28c840]" />
    </div>
  );
}

/**
 * Faux Snippeter app window: a sidebar of collections plus a syntax-highlighted
 * snippet pane. Hand-tokenized so it renders crisply with no external highlighter.
 */
function AppMock() {
  return (
    <div className="relative w-full" aria-hidden="true">
      {/* Soft brand glow behind the window */}
      <div className="absolute -inset-6 -z-10 rounded-[2rem] bg-radial-glow blur-2xl" />

      <div className="overflow-hidden rounded-2xl border border-hairline bg-surface shadow-card">
        {/* Title bar */}
        <div className="flex items-center gap-3 border-b border-hairline bg-surface-elevated px-4 py-3">
          <WindowDots />
          <div className="ml-2 flex items-center gap-2 rounded-md bg-bg/60 px-3 py-1 text-xs text-muted">
            <svg
              width="12"
              height="12"
              viewBox="0 0 24 24"
              fill="none"
              className="text-accent"
            >
              <circle
                cx="11"
                cy="11"
                r="7"
                stroke="currentColor"
                strokeWidth="2"
              />
              <path
                d="m20 20-3.5-3.5"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
              />
            </svg>
            debounce typescript
          </div>
        </div>

        <div className="grid grid-cols-[132px_1fr] sm:grid-cols-[160px_1fr]">
          {/* Sidebar */}
          <aside className="hidden border-r border-hairline bg-surface/60 p-3 text-xs sm:block">
            <p className="px-2 pb-2 font-medium uppercase tracking-wider text-muted/70">
              Collections
            </p>
            <ul className="space-y-0.5">
              {[
                ["React Hooks", true],
                ["TS Utilities", false],
                ["SQL Recipes", false],
                ["AI Prompts", false],
                ["Shell", false],
              ].map(([name, active]) => (
                <li key={name as string}>
                  <span
                    className={`flex items-center gap-2 rounded-md px-2 py-1.5 ${
                      active
                        ? "bg-accent/10 text-accent"
                        : "text-muted hover:text-ink"
                    }`}
                  >
                    <span
                      className={`h-1.5 w-1.5 rounded-full ${
                        active ? "bg-accent" : "bg-hairline"
                      }`}
                    />
                    {name}
                  </span>
                </li>
              ))}
            </ul>
            <div className="mt-4 flex flex-wrap gap-1 px-2">
              {["#async", "#util"].map((t) => (
                <span
                  key={t}
                  className="rounded-full border border-hairline px-2 py-0.5 text-[10px] text-muted"
                >
                  {t}
                </span>
              ))}
            </div>
          </aside>

          {/* Code pane */}
          <div className="scroll-thin overflow-x-auto bg-bg/40 p-4 font-mono text-[12.5px] leading-relaxed sm:p-5">
            <pre className="text-ink">
              <code>
                <span className="text-[#c792ea]">export function</span>{" "}
                <span className="text-[#82aaff]">debounce</span>
                <span className="text-muted">&lt;</span>
                <span className="text-[#f78c6c]">T</span>{" "}
                <span className="text-[#c792ea]">extends</span>{" "}
                <span className="text-[#82aaff]">unknown</span>
                <span className="text-muted">[]&gt;(</span>
                {"\n"}
                {"  "}
                <span className="text-ink">fn</span>
                <span className="text-muted">: (</span>
                <span className="text-ink">...args</span>
                <span className="text-muted">: </span>
                <span className="text-[#f78c6c]">T</span>
                <span className="text-muted">) =&gt; </span>
                <span className="text-[#82aaff]">void</span>
                <span className="text-muted">,</span>
                {"\n"}
                {"  "}
                <span className="text-ink">delay</span>
                <span className="text-muted">: </span>
                <span className="text-[#82aaff]">number</span>{" "}
                <span className="text-muted">=</span>{" "}
                <span className="text-[#f78c6c]">300</span>
                <span className="text-muted">,</span>
                {"\n"}
                <span className="text-muted">) {"{"}</span>
                {"\n"}
                {"  "}
                <span className="text-[#c792ea]">let</span>{" "}
                <span className="text-ink">timer</span>
                <span className="text-muted">: </span>
                <span className="text-[#82aaff]">ReturnType</span>
                <span className="text-muted">&lt;</span>
                <span className="text-[#c792ea]">typeof</span>{" "}
                <span className="text-ink">setTimeout</span>
                <span className="text-muted">&gt;;</span>
                {"\n\n"}
                {"  "}
                <span className="text-[#c792ea]">return</span>{" "}
                <span className="text-muted">(...</span>
                <span className="text-ink">args</span>
                <span className="text-muted">: </span>
                <span className="text-[#f78c6c]">T</span>
                <span className="text-muted">) =&gt; {"{"}</span>
                {"\n"}
                {"    "}
                <span className="text-ink">clearTimeout</span>
                <span className="text-muted">(</span>
                <span className="text-ink">timer</span>
                <span className="text-muted">);</span>
                {"\n"}
                {"    "}
                <span className="text-ink">timer</span>{" "}
                <span className="text-muted">=</span>{" "}
                <span className="text-ink">setTimeout</span>
                <span className="text-muted">(() =&gt; </span>
                <span className="text-[#82aaff]">fn</span>
                <span className="text-muted">(...</span>
                <span className="text-ink">args</span>
                <span className="text-muted">), </span>
                <span className="text-ink">delay</span>
                <span className="text-muted">);</span>
                {"\n"}
                {"  "}
                <span className="text-muted">{"};"}</span>
                {"\n"}
                <span className="text-muted">{"}"}</span>
              </code>
            </pre>

            {/* Footer status row */}
            <div className="mt-4 flex items-center justify-between border-t border-hairline pt-3 text-[11px] text-muted">
              <span className="flex items-center gap-1.5">
                <span className="h-1.5 w-1.5 rounded-full bg-accent animate-pulse-soft" />
                Saved locally
              </span>
              <span className="font-sans">TypeScript · 18 lines</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function Hero() {
  return (
    <section
      id="top"
      className="relative overflow-hidden border-b border-hairline/60"
    >
      {/* Background layers */}
      <div className="pointer-events-none absolute inset-0 -z-10 bg-grid opacity-40" />
      <div className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[520px] bg-radial-glow" />

      <div className="mx-auto grid max-w-6xl items-center gap-12 px-4 py-16 sm:px-6 lg:grid-cols-2 lg:gap-8 lg:py-24">
        <div className="animate-fade-up">
          <span className="inline-flex items-center gap-2 rounded-full border border-hairline bg-surface/60 px-3 py-1 text-xs text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-accent" />
            Local-first · 6 platforms + web
          </span>

          <h1 className="mt-6 text-balance text-4xl font-semibold leading-[1.08] tracking-tight sm:text-5xl lg:text-6xl">
            Your snippets and{" "}
            <span className="text-gradient">AI prompts</span>,
            <br className="hidden sm:block" /> everywhere you code.
          </h1>

          <p className="mt-6 max-w-xl text-pretty text-lg leading-relaxed text-muted">
            Snippeter is a fast, local-first manager for code snippets and AI
            prompts. Everything lives on your device first — instant FTS5 search,
            carbon-style image export, and end-to-end encrypted sync across all
            six platforms and the web.
          </p>

          <div className="mt-8 flex flex-col gap-3 sm:flex-row">
            {/* Primary CTA → deployed web app (replace "#" when live) */}
            <CtaButton href="#" variant="primary" size="lg">
              Open Snippeter
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <path
                  d="M5 12h14m-6-6 6 6-6 6"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </CtaButton>
            <CtaButton href="#features" variant="secondary" size="lg">
              See how it works
            </CtaButton>
          </div>

          <dl className="mt-10 grid max-w-md grid-cols-3 gap-4 border-t border-hairline pt-6">
            {[
              ["6 + web", "native platforms"],
              ["600+", "languages detected"],
              ["100%", "works offline"],
            ].map(([stat, label]) => (
              <div key={label}>
                <dt className="text-2xl font-semibold tracking-tight text-ink">
                  {stat}
                </dt>
                <dd className="mt-1 text-xs text-muted">{label}</dd>
              </div>
            ))}
          </dl>
        </div>

        <div className="animate-fade-up lg:pl-6 [animation-delay:120ms]">
          <AppMock />
        </div>
      </div>
    </section>
  );
}
