const plugin = require("tailwindcss/plugin");

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./js/**/*.js",
    "./js/**/*.ts",
    "../lib/bun2nix_phoenix_web.ex",
    "../lib/bun2nix_phoenix_web/**/*.*ex",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("daisyui"),
    plugin(function ({ addVariant }) {
      addVariant("phx-no-feedback", [
        "&.phx-no-feedback",
        ".phx-no-feedback &",
      ]);
      addVariant("phx-click-loading", [
        "&.phx-click-loading",
        ".phx-click-loading &",
      ]);
      addVariant("phx-submit-loading", [
        "&.phx-submit-loading",
        ".phx-submit-loading &",
      ]);
      addVariant("phx-change-loading", [
        "&.phx-change-loading",
        ".phx-change-loading &",
      ]);
    }),
  ],
  daisyui: {
    themes: [
      {
        dark: {
          "--color-base-100": "oklch(30.33% 0.016 252.42)",
          "--color-base-200": "oklch(25.26% 0.014 253.1)",
          "--color-base-300": "oklch(20.15% 0.012 254.09)",
          "--color-base-content": "oklch(97.807% 0.029 256.847)",
          "--color-primary": "oklch(58% 0.233 277.117)",
          "--color-primary-content": "oklch(96% 0.018 272.314)",
          "--color-secondary": "oklch(58% 0.233 277.117)",
          "--color-secondary-content": "oklch(96% 0.018 272.314)",
          "--color-accent": "oklch(60% 0.25 292.717)",
          "--color-accent-content": "oklch(96% 0.016 293.756)",
          "--color-neutral": "oklch(37% 0.044 257.287)",
          "--color-neutral-content": "oklch(98% 0.003 247.858)",
          "--color-info": "oklch(58% 0.158 241.966)",
          "--color-info-content": "oklch(97% 0.013 236.62)",
          "--color-success": "oklch(60% 0.118 184.704)",
          "--color-success-content": "oklch(98% 0.014 180.72)",
          "--color-warning": "oklch(66% 0.179 58.318)",
          "--color-warning-content": "oklch(98% 0.022 95.277)",
          "--color-error": "oklch(58% 0.253 17.585)",
          "--color-error-content": "oklch(96% 0.015 12.422)",
          "--radius-selector": "0.25rem",
          "--radius-field": "0.25rem",
          "--radius-box": "0.5rem",
          "--size-selector": "0.21875rem",
          "--size-field": "0.21875rem",
          "--border": "1.5px",
          "--depth": "1",
          "--noise": "0",
        },
      },
      {
        light: {
          "--color-base-100": "oklch(98% 0 0)",
          "--color-base-200": "oklch(96% 0.001 286.375)",
          "--color-base-300": "oklch(92% 0.004 286.32)",
          "--color-base-content": "oklch(21% 0.006 285.885)",
          "--color-primary": "oklch(70% 0.213 47.604)",
          "--color-primary-content": "oklch(98% 0.016 73.684)",
          "--color-secondary": "oklch(55% 0.027 264.364)",
          "--color-secondary-content": "oklch(98% 0.002 247.839)",
          "--color-accent": "oklch(0% 0 0)",
          "--color-accent-content": "oklch(100% 0 0)",
          "--color-neutral": "oklch(44% 0.017 285.786)",
          "--color-neutral-content": "oklch(98% 0 0)",
          "--color-info": "oklch(62% 0.214 259.815)",
          "--color-info-content": "oklch(97% 0.014 254.604)",
          "--color-success": "oklch(70% 0.14 182.503)",
          "--color-success-content": "oklch(98% 0.014 180.72)",
          "--color-warning": "oklch(66% 0.179 58.318)",
          "--color-warning-content": "oklch(98% 0.022 95.277)",
          "--color-error": "oklch(58% 0.253 17.585)",
          "--color-error-content": "oklch(96% 0.015 12.422)",
          "--radius-selector": "0.25rem",
          "--radius-field": "0.25rem",
          "--radius-box": "0.5rem",
          "--size-selector": "0.21875rem",
          "--size-field": "0.21875rem",
          "--border": "1.5px",
          "--depth": "1",
          "--noise": "0",
        },
      },
    ],
    darkTheme: "dark",
  },
};
