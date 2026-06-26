import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";

type Variant = "primary" | "secondary" | "ghost";
type Size = "md" | "lg";

type CtaButtonProps = {
  href: string;
  children: ReactNode;
  variant?: Variant;
  size?: Size;
  className?: string;
  /** When the destination is external (e.g. GitHub), open in a new tab. */
  external?: boolean;
} & Omit<ComponentProps<typeof Link>, "href" | "className">;

const base =
  "inline-flex items-center justify-center gap-2 rounded-xl font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent focus-visible:ring-offset-2 focus-visible:ring-offset-bg disabled:cursor-not-allowed disabled:opacity-60";

const variants: Record<Variant, string> = {
  primary:
    "bg-brand-gradient text-[#0B0C0F] shadow-[0_8px_30px_-8px_rgba(101,234,146,0.6)] hover:shadow-[0_12px_40px_-8px_rgba(101,234,146,0.75)] hover:-translate-y-0.5 active:translate-y-0",
  secondary:
    "border border-hairline bg-surface-elevated text-ink hover:border-accent/50 hover:bg-surface-elevated/80 hover:-translate-y-0.5 active:translate-y-0",
  ghost: "text-ink hover:text-accent",
};

const sizes: Record<Size, string> = {
  md: "px-4 py-2 text-sm",
  lg: "px-6 py-3 text-base",
};

export default function CtaButton({
  href,
  children,
  variant = "primary",
  size = "md",
  className = "",
  external = false,
  ...rest
}: CtaButtonProps) {
  const classes = `${base} ${variants[variant]} ${sizes[size]} ${className}`;
  const externalProps = external
    ? { target: "_blank", rel: "noopener noreferrer" }
    : {};

  return (
    <Link href={href} className={classes} {...externalProps} {...rest}>
      {children}
    </Link>
  );
}
