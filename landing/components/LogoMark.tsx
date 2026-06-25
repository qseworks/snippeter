type LogoMarkProps = {
  /** Pixel size of the rounded square. */
  size?: number;
  className?: string;
};

/**
 * Snippeter logo mark: the glyph "</>" in white inside a rounded square
 * with a green → teal brand gradient. Drawn inline (no external asset).
 */
export default function LogoMark({ size = 32, className }: LogoMarkProps) {
  // Unique gradient id per size avoids collisions when several marks render.
  const gradientId = `snippeter-mark-${size}`;
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 64 64"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="Snippeter logo"
      className={className}
    >
      <defs>
        <linearGradient
          id={gradientId}
          x1="0"
          y1="0"
          x2="64"
          y2="64"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#16B378" />
          <stop offset="1" stopColor="#12A594" />
        </linearGradient>
      </defs>
      <rect width="64" height="64" rx="16" fill={`url(#${gradientId})`} />
      <path
        d="M25.5 22.5L17 32L25.5 41.5M38.5 22.5L47 32L38.5 41.5M34.5 19L29.5 45"
        stroke="white"
        strokeWidth="4.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
