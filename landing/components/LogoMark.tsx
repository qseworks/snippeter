type LogoMarkProps = {
  /** Pixel size of the rounded square. */
  size?: number;
  /**
   * When true, the green block caret blinks like a terminal cursor (gated behind
   * `motion-safe`, so it holds steady for `prefers-reduced-motion`). The chevron
   * and tile stay solid, so the mark still reads as the brand favicon. Defaults
   * to false to match the generated (static) PNG/ICO favicons.
   */
  blink?: boolean;
  /**
   * When true, the mark is hidden from assistive tech (aria-hidden). Use this
   * when an adjacent text wordmark already names the element, to avoid a doubled
   * "Snippeter logo Snippeter" announcement.
   */
  decorative?: boolean;
  /**
   * Disambiguates the internal gradient ids. Gradient ids are otherwise keyed by
   * `size` alone, so two same-size marks in one document would emit duplicate ids
   * (invalid HTML). Pass a distinct value per call site (e.g. "nav" / "footer").
   */
  idSuffix?: string;
  className?: string;
};

/**
 * Snippeter logo mark: the "prompt" glyph — a terminal chevron ">" plus a green
 * block caret (reads as ">▍") — on a dark machined tile. Drawn inline (no external
 * asset) to match brand/icon.svg geometry. viewBox is 512×512; everything scales
 * linearly with `size`.
 */
export default function LogoMark({
  size = 32,
  blink = false,
  decorative = false,
  idSuffix,
  className,
}: LogoMarkProps) {
  // Gradient ids must be unique per document; key by size + an optional caller
  // suffix so two same-size marks don't collide.
  const uid = idSuffix ? `${size}-${idSuffix}` : `${size}`;
  const tileId = `snippeter-tile-${uid}`;
  const glowId = `snippeter-glow-${uid}`;
  const caretId = `snippeter-caret-${uid}`;
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 512 512"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      {...(decorative
        ? { "aria-hidden": true }
        : { role: "img", "aria-label": "Snippeter logo" })}
      className={className}
    >
      <defs>
        <linearGradient
          id={tileId}
          x1="147.8"
          y1="24"
          x2="364.2"
          y2="488"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#1C1F27" />
          <stop offset="1" stopColor="#111319" />
        </linearGradient>
        <radialGradient
          id={glowId}
          cx="328"
          cy="246"
          r="236"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#65EA92" stopOpacity="0.16" />
          <stop offset="0.72" stopColor="#65EA92" stopOpacity="0" />
        </radialGradient>
        <linearGradient
          id={caretId}
          x1="0"
          y1="0"
          x2="0"
          y2="34"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#7CF5A2" />
          <stop offset="1" stopColor="#5EE38B" />
        </linearGradient>
      </defs>

      {/* Dark machined tile + soft green glow */}
      <rect width="512" height="512" rx="114" fill={`url(#${tileId})`} />
      <rect width="512" height="512" rx="114" fill={`url(#${glowId})`} />
      {/* Subtle inset ring just inside the tile edge */}
      <rect
        x="1.5"
        y="1.5"
        width="509"
        height="509"
        rx="112.5"
        fill="none"
        stroke="#24272F"
        strokeWidth="3"
      />

      {/* Glyph: chevron ">" + green block caret */}
      <g transform="translate(173.02 173.02) scale(4.881)">
        <path
          d="M0 0 L17 17 L0 34"
          fill="none"
          stroke="#EDEEF2"
          strokeWidth="8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <rect
          x="27"
          y="0"
          width="11"
          height="34"
          rx="4"
          fill={`url(#${caretId})`}
          className={blink ? "motion-safe:animate-blink" : undefined}
        />
      </g>
    </svg>
  );
}
