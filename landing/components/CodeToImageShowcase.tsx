/**
 * CodeToImageShowcase — a "carbon-style" exported snippet rendered as a
 * shareable image card, framed inside an export preview. Pure CSS/SVG.
 */

function ExportedCard() {
  return (
    <div className="relative mx-auto w-full max-w-lg">
      {/* The colorful gradient frame that carbon-style exports sit on */}
      <div className="rounded-2xl bg-[linear-gradient(135deg,#7CF5A2_0%,#5EE38B_55%,#259F56_100%)] p-5 shadow-[0_30px_80px_-30px_rgba(101,234,146,0.6)] sm:p-8">
        <div className="overflow-hidden rounded-xl border border-black/30 bg-[#0c0e12] shadow-2xl">
          {/* Window chrome */}
          <div className="flex items-center gap-1.5 border-b border-white/5 px-4 py-3">
            <span className="h-3 w-3 rounded-full bg-[#ff5f57]" />
            <span className="h-3 w-3 rounded-full bg-[#febc2e]" />
            <span className="h-3 w-3 rounded-full bg-[#28c840]" />
            <span className="ml-3 text-[11px] text-muted">
              retry.py
            </span>
          </div>

          {/* Highlighted code */}
          <pre className="overflow-x-auto px-5 py-5 font-mono text-[12.5px] leading-relaxed">
            <code>
              <span className="select-none pr-4 text-white/20">1</span>
              <span className="text-[#c792ea]">import</span>{" "}
              <span className="text-ink">time, functools</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">2</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">3</span>
              <span className="text-[#c792ea]">def</span>{" "}
              <span className="text-[#82aaff]">retry</span>
              <span className="text-muted">(</span>
              <span className="text-ink">times</span>
              <span className="text-muted">=</span>
              <span className="text-[#f78c6c]">3</span>
              <span className="text-muted">, </span>
              <span className="text-ink">delay</span>
              <span className="text-muted">=</span>
              <span className="text-[#f78c6c]">0.5</span>
              <span className="text-muted">):</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">4</span>
              {"    "}
              <span className="text-[#c792ea]">def</span>{" "}
              <span className="text-[#82aaff]">wrap</span>
              <span className="text-muted">(</span>
              <span className="text-ink">fn</span>
              <span className="text-muted">):</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">5</span>
              {"        "}
              <span className="text-[#82aaff]">@functools.wraps</span>
              <span className="text-muted">(</span>
              <span className="text-ink">fn</span>
              <span className="text-muted">)</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">6</span>
              {"        "}
              <span className="text-[#c792ea]">def</span>{" "}
              <span className="text-[#82aaff]">inner</span>
              <span className="text-muted">(*</span>
              <span className="text-ink">a</span>
              <span className="text-muted">, **</span>
              <span className="text-ink">kw</span>
              <span className="text-muted">):</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">7</span>
              {"            "}
              <span className="text-[#c792ea]">for</span>{" "}
              <span className="text-ink">i</span>{" "}
              <span className="text-[#c792ea]">in</span>{" "}
              <span className="text-[#82aaff]">range</span>
              <span className="text-muted">(</span>
              <span className="text-ink">times</span>
              <span className="text-muted">):</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">8</span>
              {"                "}
              <span className="text-[#c792ea]">try</span>
              <span className="text-muted">:</span>{" "}
              <span className="text-[#c792ea]">return</span>{" "}
              <span className="text-ink">fn</span>
              <span className="text-muted">(*</span>
              <span className="text-ink">a</span>
              <span className="text-muted">, **</span>
              <span className="text-ink">kw</span>
              <span className="text-muted">)</span>
              {"\n"}
              <span className="select-none pr-4 text-white/20">9</span>
              {"                "}
              <span className="text-[#c792ea]">except</span>{" "}
              <span className="text-[#ffcb6b]">Exception</span>
              <span className="text-muted">: </span>
              <span className="text-ink">time</span>
              <span className="text-muted">.</span>
              <span className="text-[#82aaff]">sleep</span>
              <span className="text-muted">(</span>
              <span className="text-ink">delay</span>
              <span className="text-muted">)</span>
            </code>
          </pre>
        </div>
        <p className="mt-3 text-center text-[11px] font-medium text-[#0B0C0F]/75">
          snippeter · Dracula theme · PNG @2x
        </p>
      </div>

      {/* Floating "exporting" chip */}
      <div className="absolute -bottom-3 -right-3 flex items-center gap-2 rounded-xl border border-hairline bg-surface-elevated px-3 py-2 text-xs shadow-card">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path
            d="M12 3v12m0 0 4-4m-4 4-4-4M5 21h14"
            stroke="#65EA92"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
        Exported retry.png
      </div>
    </div>
  );
}

export default function CodeToImageShowcase() {
  return (
    <section className="relative overflow-hidden py-20 sm:py-24">
      <div className="pointer-events-none absolute inset-0 -z-10 bg-radial-glow opacity-60" />
      <div className="mx-auto grid max-w-6xl items-center gap-14 px-4 sm:px-6 lg:grid-cols-2 lg:gap-12">
        <div>
          <p className="text-sm font-medium uppercase tracking-wider text-accent">
            Code → image
          </p>
          <h2 className="mt-3 text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
            Turn a snippet into something worth sharing
          </h2>
          <p className="mt-4 text-pretty text-muted">
            Every snippet can become a clean, carbon-style image in a couple of
            keystrokes. Choose a theme, set the padding and window frame, then
            export crisp PNG or SVG at up to 2× — perfect for pull requests,
            docs, slides and social.
          </p>

          <ul className="mt-8 space-y-3">
            {[
              "Syntax highlighting for 600+ languages, auto-detected",
              "Light & dark themes with adjustable padding and frame",
              "PNG or SVG export, plus shareable image links on Pro",
              "Built into the free tier — no separate web tool needed",
            ].map((item) => (
              <li key={item} className="flex items-start gap-3 text-sm">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  className="mt-0.5 shrink-0 text-accent"
                  aria-hidden
                >
                  <circle
                    cx="12"
                    cy="12"
                    r="9"
                    stroke="currentColor"
                    strokeWidth="1.6"
                    opacity="0.4"
                  />
                  <path
                    d="m8.5 12 2.5 2.5 4.5-5"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
                <span className="text-muted">{item}</span>
              </li>
            ))}
          </ul>
        </div>

        <div className="pt-4 lg:pt-0">
          <ExportedCard />
        </div>
      </div>
    </section>
  );
}
