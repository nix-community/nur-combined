import solidPlugin from "@opentui/solid/bun-plugin";

const result = await Bun.build({
  entrypoints: ["./tui.tsx"],
  outdir: "./dist",
  target: "bun",
  format: "esm",
  plugins: [solidPlugin],
});

if (!result.success) {
  for (const log of result.logs) {
    console.error(log);
  }
  process.exit(1);
}
