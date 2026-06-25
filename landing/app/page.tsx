import Nav from "@/components/Nav";
import Hero from "@/components/Hero";
import FeatureGrid from "@/components/FeatureGrid";
import IntegrationsStrip from "@/components/IntegrationsStrip";
import CodeToImageShowcase from "@/components/CodeToImageShowcase";
import Pricing from "@/components/Pricing";
import Faq from "@/components/Faq";
import Footer from "@/components/Footer";
import CtaButton from "@/components/CtaButton";

export default function Home() {
  return (
    <>
      {/* Accessibility: lets keyboard users jump past the nav */}
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[60] focus:rounded-lg focus:bg-surface-elevated focus:px-4 focus:py-2 focus:text-sm focus:text-ink focus:shadow-glow"
      >
        Skip to content
      </a>

      <Nav />

      <main id="main">
        <Hero />
        <FeatureGrid />
        <IntegrationsStrip />
        <CodeToImageShowcase />
        <Pricing />
        <Faq />

        {/* Closing call-to-action band */}
        <section className="relative overflow-hidden border-t border-hairline/60 py-20 sm:py-24">
          <div className="pointer-events-none absolute inset-0 -z-10 bg-radial-glow" />
          <div className="mx-auto max-w-3xl px-4 text-center sm:px-6">
            <h2 className="text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
              Start with the free app. Keep everything you build.
            </h2>
            <p className="mx-auto mt-4 max-w-xl text-pretty text-muted">
              Install Snippeter on every device you own, organize your snippets
              and prompts the way you think, and upgrade only when you want them
              synced everywhere.
            </p>
            <div className="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
              {/* Primary CTA → deployed web app (replace "#" when live) */}
              <CtaButton href="#" variant="primary" size="lg">
                Open Snippeter
              </CtaButton>
              <CtaButton href="#pricing" variant="secondary" size="lg">
                Compare plans
              </CtaButton>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </>
  );
}
