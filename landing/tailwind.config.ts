import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx,mdx}",
    "./components/**/*.{ts,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Snippeter brand tokens
        accent: {
          DEFAULT: "#65EA92", // brand green (caret/accent on dark)
          green: "#65EA92",
          teal: "#5EE38B", // green deep (caret gradient bottom)
        },
        bg: "#0F1115", // dark background
        surface: {
          DEFAULT: "#161A21", // surface
          elevated: "#1C212B", // elevated surface
        },
        hairline: "#262B36", // hairline border
        ink: "#E6E9EF", // text
        muted: "#8A93A2", // muted text
      },
      fontFamily: {
        sans: ["var(--font-inter)", "system-ui", "sans-serif"],
        display: ["var(--font-grotesk)", "var(--font-inter)", "sans-serif"],
        mono: [
          "ui-monospace",
          "SFMono-Regular",
          "Menlo",
          "Consolas",
          "Liberation Mono",
          "monospace",
        ],
      },
      borderRadius: {
        "2xl": "1rem",
        "3xl": "1.5rem",
      },
      boxShadow: {
        glow: "0 0 0 1px rgba(101,234,146,0.18), 0 18px 60px -20px rgba(101,234,146,0.35)",
        card: "0 1px 0 0 rgba(255,255,255,0.02), 0 20px 50px -30px rgba(0,0,0,0.8)",
      },
      backgroundImage: {
        "brand-gradient": "linear-gradient(135deg, #7CF5A2 0%, #5EE38B 100%)",
        "radial-glow":
          "radial-gradient(60% 60% at 50% 0%, rgba(101,234,146,0.14) 0%, rgba(15,17,21,0) 70%)",
      },
      keyframes: {
        "fade-up": {
          "0%": { opacity: "0", transform: "translateY(12px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        "pulse-soft": {
          "0%, 100%": { opacity: "1" },
          "50%": { opacity: "0.55" },
        },
        // Hard on/off terminal-cursor blink (steps, no fade) for the brand caret.
        blink: {
          "0%, 48%": { opacity: "1" },
          "50%, 100%": { opacity: "0" },
        },
      },
      animation: {
        "fade-up": "fade-up 0.6s ease-out both",
        "pulse-soft": "pulse-soft 2.6s ease-in-out infinite",
        blink: "blink 1.15s steps(1) infinite",
      },
    },
  },
  plugins: [],
};

export default config;
