# OpenCode Plugin Packaging Guide

This guide is for agents adding or updating packages under `pkgs/opencode/plugins`.

## Objective

Package each plugin so OpenCode can load multiple plugins reliably from Nix store
paths with no runtime rebuild hacks.

## Rules That Must Hold

1. Consumer configs must reference plugin package roots, not explicit entry files.
   - Use: `file://${pkg}`
   - Do not use: `file://${pkg}/dist/index.js`
2. Package root import must resolve to runtime JavaScript.
   - `package.json` `main` must point to built JS (usually `dist/index.js`).
3. All required generated files must exist in `$out`.
   - If plugin needs codegen/build, run it in `postInstall`.
4. Plugin package must pass both build-time and import-time checks before merge.

## Current Builder Contract

`mkOpencodePlugin` in `pkgs/opencode/plugins/default.nix`:

- Copies dependencies to `./node_modules`.
- Copies source tree to `$out`.
- Runs `postInstall` after files are in `$out`.
- Supports per-plugin toolchain extensions via:
  - `nativeBuildInputs = [bun] ++ (args.nativeBuildInputs or [])`

Implication: `postInstall` should usually start with `cd "$out"`.

## New Plugin Workflow

1. Create `pkgs/opencode/plugins/<name>/default.nix`.
2. Choose dependency strategy:
   - `dependencyHash = null` for no external npm deps.
   - Set `dependencyHash` for plugins requiring `node_modules`.
3. Add build/codegen in `postInstall` if upstream ships TS or generated assets.
4. Ensure output `package.json` `main` resolves to JS at runtime.
5. Build and smoke-test import.
6. Update consumer config to use package-root URL (`file://${pkg}`).

## Template

```nix
{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
  # Add toolchain deps only when required by build/codegen.
  typescript ? null,
}:
mkOpencodePlugin rec {
  pname = "<plugin-name>";
  version = "<version>";

  src = fetchFromGitHub {
    owner = "<owner>";
    repo = "<repo>";
    rev = "v${version}";
    hash = "sha256-...";
  };

  # Use null if plugin has no runtime npm dependencies.
  dependencyHash = "sha256-...";

  # Optional: add per-plugin build tools.
  nativeBuildInputs = lib.optionals (typescript != null) [typescript];

  # Optional: build JS and generated assets inside $out.
  postInstall = ''
    cd "$out"

    # Example build steps (adjust per plugin).
    bun run build

    # If upstream main points to TS, rewrite to built JS.
    substituteInPlace package.json \
      --replace-fail '"main": "index.ts"' '"main": "dist/index.js"'
  '';

  meta = {
    description = "<description>";
    homepage = "https://github.com/<owner>/<repo>";
    license = lib.licenses.mit;
  };
}
```

## Validation Checklist

For plugin `<name>`:

1. Build:

```bash
nix-build -A opencodePlugins.<name> --no-out-link
```

2. Import package root (not a file inside dist):

```bash
out=$(nix-build -A opencodePlugins.<name> --no-out-link)
bun -e "await import('file://$out'); console.log('ok')"
```

3. Verify all plugins still load together:

```bash
opencode debug config --print-logs --log-level DEBUG
```

Look for one `service=plugin path=file:///nix/store/...` line per plugin.

## Known Failure Modes

- Symptom: only one custom plugin appears loaded.
  - Cause: explicit `.../dist/index.js` plugin URLs.
  - Fix: switch all plugin URLs to package roots (`file://${pkg}`).

- Symptom: `Cannot find module` for generated files.
  - Cause: codegen step missing.
  - Fix: run generator in `postInstall` before compile.

- Symptom: package-root import fails but `dist/index.js` exists.
  - Cause: `package.json` `main` still points to TS.
  - Fix: rewrite `main` to `dist/index.js` in `postInstall`.

- Symptom: TS compile fails in sandbox due missing toolchain.
  - Cause: build tools not present.
  - Fix: add tools via `nativeBuildInputs` (for example `typescript`).

## Existing Package Patterns

- `cc-safety-net`: no extra build step.
- `dynamic-context-pruning`: prompt generation + `tsc` compile.
- `notifier`: upstream build script (`bun run build`).
- `morph-fast-apply`: direct bun build + main rewrite.
- `unmoji`: `fetchFromCodeberg` + direct
  `bun build src/index.ts --outdir dist --target node --format esm`.

## Consumer Config Pattern

In Home Manager/NixOS config, load package roots only:

```nix
programs.opencode.settings.plugin = [
  "file://${pkgs.nur.repos.adam0.opencodePlugins.<name>}"
];
```
