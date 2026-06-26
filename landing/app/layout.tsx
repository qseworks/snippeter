import type { Metadata, Viewport } from "next";
import { Inter, Space_Grotesk } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
});

// Space Grotesk powers the "Snippeter" wordmark (SemiBold).
const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  weight: ["500", "600", "700"],
  display: "swap",
  variable: "--font-grotesk",
});

const siteUrl = "https://snippeter.app";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "Snippeter — snippets & AI prompts, everywhere",
  description:
    "Snippeter is a fast, local-first manager for code snippets and AI prompts. FTS5 full-text search, carbon-style code-to-image export, and end-to-end encrypted sync across Windows, Linux, macOS, iOS, Android and the web.",
  applicationName: "Snippeter",
  authors: [{ name: "Snippeter" }],
  keywords: [
    "code snippets",
    "snippet manager",
    "AI prompts",
    "prompt manager",
    "local-first",
    "code to image",
    "carbon export",
    "developer tools",
    "Flutter app",
    "VS Code snippets",
  ],
  alternates: {
    canonical: siteUrl,
  },
  openGraph: {
    type: "website",
    url: siteUrl,
    siteName: "Snippeter",
    title: "Snippeter — snippets & AI prompts, everywhere",
    description:
      "A fast, local-first manager for code snippets and AI prompts. Full-text search, code-to-image export, and encrypted sync across all six platforms and the web.",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "Snippeter — snippets & AI prompts, everywhere",
    description:
      "A fast, local-first manager for code snippets and AI prompts. Full-text search, code-to-image export, and encrypted sync everywhere.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  themeColor: "#65EA92",
  colorScheme: "dark",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${spaceGrotesk.variable}`}>
      <body className="min-h-screen bg-bg font-sans text-ink antialiased">
        {children}
      </body>
    </html>
  );
}
