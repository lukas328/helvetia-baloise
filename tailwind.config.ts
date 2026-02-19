import type { Config } from "tailwindcss";

export default {
  darkMode: ["class"],
  content: ["./pages/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./app/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        background: "#0B1220",
        card: "#111A2E",
        border: "#22304D",
        foreground: "#E8EEF9",
        muted: "#A7B3C9",
        accent: "#19D3A2",
        warning: "#FFB020",
        danger: "#FF4D4D"
      }
    }
  },
  plugins: [],
} satisfies Config;
