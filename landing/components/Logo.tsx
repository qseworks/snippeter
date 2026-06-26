import LogoMark from "./LogoMark";

type LogoProps = {
  /** Pixel size of the icon tile. Defaults to the nav/footer lockup size. */
  size?: number;
  /**
   * Distinguishes this instance's internal gradient ids from other lockups on
   * the same page (e.g. "nav" vs "footer"), avoiding duplicate DOM ids.
   */
  idSuffix?: string;
  className?: string;
};

/**
 * Snippeter brand lockup: the prompt mark next to the "Snippeter" wordmark with a
 * blinking green block caret trailing the word — the lockup reads as a live
 * terminal prompt ("Snippeter▍"). Mirrors the primary lockup from the brand
 * design doc (Snippeter Logo.dc.html). Shared by the nav and footer.
 *
 * Render this inside the link/anchor that owns the brand's focus ring. The mark
 * and caret are decorative (aria-hidden); the visible "Snippeter" text is the
 * sole accessible name, so the wrapping link announces simply as "Snippeter".
 */
export default function Logo({ size = 30, idSuffix, className }: LogoProps) {
  return (
    <span className={`inline-flex items-center gap-2.5 ${className ?? ""}`}>
      <LogoMark size={size} idSuffix={idSuffix} decorative />
      <span className="inline-flex items-center font-display text-lg font-semibold tracking-tight">
        Snippeter
        {/* Blinking block caret — the "cursor" of the prompt mark. Decorative, so
            hidden from AT. Sized in em so it tracks the wordmark; nudged down to
            sit on the baseline. Gated behind motion-safe so it holds steady for
            prefers-reduced-motion. */}
        <span
          aria-hidden="true"
          className="ml-[0.16em] inline-block h-[0.78em] w-[0.19em] min-w-[3px] translate-y-[0.05em] rounded-[1px] bg-brand-gradient shadow-[0_0_10px_rgba(101,234,146,0.45)] motion-safe:animate-blink"
        />
      </span>
    </span>
  );
}
