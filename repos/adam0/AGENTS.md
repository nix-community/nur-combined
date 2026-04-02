# Agent Instructions

## OpenCode plugin packaging

When adding or updating any package in `pkgs/opencode/plugins`, follow:

- `pkgs/opencode/plugins/README.md`

Required checks before finishing:

1. `nix-build -A opencodePlugins.<name> --no-out-link` succeeds.
2. Package-root import works: `bun -e "await import('file://$out')"`.
3. Do not use explicit plugin entrypoint URLs like `/dist/index.js` in consumer
   configs. Use package roots (`file://${pkg}`) so multiple plugins can load
   together.
