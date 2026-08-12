# PLAN — package `opencodex` in NUR

## Goal
Add `pkgs.opencodex` (universal provider proxy for OpenAI Codex / Claude Code)
to the NUR, built **from Git source at `v2.13.0`**, including the bundled web
dashboard (GUI), so the user can then hook it up to `codex-cli`.

## Context (research findings)
- **Runtime model:** opencodex ships as **TypeScript sources executed directly by
  Bun** — there is **no compile step** at the root. `bin/ocx.mjs` is a plain Node
  shim that spawns `bun <pkg>/src/cli/index.ts ...`.
- **Bun resolution:** the launcher checks the `OPENCODEX_BUN_PATH` env var
  **first**; if it points at a real bun binary it is used and the bundled `bun`
  npm dependency is never touched. Use `pkgs.bun` via a wrapper.
- **Native deps** (`@napi-rs/keyring`, `@oven/bun-*`) are prebuilt platform
  npm packages — no build step required at install.
- **Blockers for the stock npm path:**
  - Repo uses `bun.lock` (not `package-lock.json`); nixpkgs has **no**
    `buildBunPackage` / `fetchBunDeps` tooling.
  - Git source tarball has **no** `gui/dist` — the dashboard must be built
    (`tsc -b && vite build`) from `gui/`.
  - `npmConfigHook` **requires** `package-lock.json` present in the source,
    byte-identical to the one used for `npmDepsHash`. => vendor the lockfiles.
- nixpkgs `bun` is 1.3.13 vs opencodex's bundled 1.3.14 — minor-close, fine at
  runtime.

## Assets / hashes (already computed)
| Item | Value |
|---|---|
| upstream `rev` | `21e3878011bf94863fe94c38edd2c8f51f48df6d` (tag `v2.13.0`) |
| `src.hash` | `sha256-IZLVVUbVRirOwNmPRyr/3VI1zE0c85TaAHEoOgi+iwg=` |
| root `npmDepsHash` | `sha256-xHJUGAwUbK7Q5uMTMI75Z4/MUHX/fdnCo1Z4S0s6WY8=` (lock regenerated **without** the `bun` dep) |
| gui `npmDepsHash` | `sha256-BvFAFT3Gegf759AdZIlO5s6aKQSFji1282UGKnT2Xo0=` |

## Files
- `pkgs/opencodex/default.nix` — **single** derivation file. Two `buildNpmPackage`
  calls composed via `let in`:
  1. `gui` — builds `gui/` (sourceRoot `source/gui`) into a `dist` output.
  2. main `opencodex` — installs the root package; copies the built `gui.dist`
     into `package/gui/dist` before `npm pack`; wraps the `ocx` bin with
     `OPENCODEX_BUN_PATH`. `passthru.updateScript = ./update.sh`.
- `pkgs/opencodex/update.sh` — custom updater (bumps version, regenerates both
  lockfiles, recomputes hashes).
- `pkgs/opencodex/package-lock.json` — vendored root lockfile (generated with
  `npm install --package-lock-only --ignore-scripts`).
- `pkgs/opencodex/gui-package-lock.json` — vendored `gui/` lockfile (same).
  *(committing lockfiles is required for hermetic `npmConfigHook` validation;
  this is data, not a split of the package definition.)*
- `pkgs/default.nix` — register `opencodex = final.callPackage ./opencodex { };`
  (keep alphabetical order).

## Derivation sketch (`default.nix`, one file, `let in`)
```nix
{ lib, buildNpmPackage, fetchFromGitHub, bun, versionCheckHook, ... }:
let
  version = "2.13.0";
  src = fetchFromGitHub { owner = "lidge-jun"; repo = "opencodex";
    rev = "v${version}"; hash = "sha256-IZLVVUbVRirOwNmPRyr/3VI1zE0c85TaAHEoOgi+iwg="; };
  packageLock = ./package-lock.json;
  guiPackageLock = ./gui-package-lock.json;

  gui = buildNpmPackage {
    pname = "opencodex-gui"; inherit version;
    inherit src;
    sourceRoot = "${src.name}/gui";
    npmDepsHash = "sha256-BvFAFT3Gegf759AdZIlO5s6aKQSFji1282UGKnT2Xo0=";
    postPatch = "cp ${guiPackageLock} package-lock.json";
    # npmBuildScript = "build"  (tsc -b && vite build) -> dist/
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/
      runHook postInstall
    '';
  };
in
buildNpmPackage {
  pname = "opencodex"; inherit version src;
  npmDepsHash = "sha256-xHJUGAwUbK7Q5uMTMI75Z4/MUHX/fdnCo1Z4S0s6WY8=";
  dontNpmBuild = true;
  npmPackFlags = [ "--ignore-scripts" ];
  postPatch = "cp ${packageLock} package-lock.json; awk '!/\"bun\":/' package.json > t && mv t package.json";  # strip bun dep
  preInstall = "mkdir -p gui && cp -r ${gui}/dist gui/dist";
  postFixup = ''
    wrapProgram $out/bin/ocx \
      --set OPENCODEX_BUN_PATH ${lib.getExe bun} \
      --prefix PATH : ${lib.makeBinPath [ bun ]}
  '';
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = ./update.sh;  # bumps version, regenerates lockfiles + hashes
  meta = with lib; {
    description = "Universal provider proxy for OpenAI Codex & Claude Code";
    longDescription = ''
      Use any LLM (Claude, Gemini, Grok, DeepSeek, Ollama, ...) with Codex CLI,
      App, SDK, and Claude Code. Provides a local proxy translating Codex's
      Responses API into whatever provider you point at, plus a web dashboard.
    '';
    homepage = "https://github.com/lidge-jun/opencodex";
    changelog = "https://github.com/lidge-jun/opencodex/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "ocx";
  };
}
```

## Steps
1. Write `PLAN.md` (this file). ✅
2. Compute `src.hash`, root + gui `npmDepsHash` (done, above).
3. Generate + vendor both `package-lock.json` files into `pkgs/opencodex/`.
4. Write `pkgs/opencodex/default.nix` (single file, `let in`).
5. Register in `pkgs/default.nix`.
6. `nix build .#opencodex`; fix hashes/flags as needed.
7. Verify: `result/bin/ocx --help`, `ocx --version`; brief `ocx start` on a temp
   port + `/healthz`, then `ocx stop`.
8. Write `pkgs/opencodex/update.sh`, wire `passthru.updateScript`, and test the
   pipeline (forced old version → regenerated lockfiles byte-identical).
9. `nixfmt` + commit `feat(pkgs): add opencodex`.

## Risks / notes
- **Updater: `pkgs/opencodex/update.sh`** (custom, `passthru.updateScript = ./update.sh`).
  `nix-update-script` alone cannot work here: it bumps `version`/`src`/`npmDepsHash`
  but would not regenerate the vendored npm lockfiles (upstream ships only `bun.lock`,
  nixpkgs has no bun-lockfile tooling). `update.sh` therefore does the whole job:
  fetch the new `vX.Y.Z` source, regenerate both `package-lock.json` files with
  `npm install --package-lock-only --ignore-scripts` (root has the `bun` dep
  stripped), recompute `src.hash`, root + gui `npmDepsHash`, and patch `default.nix`
  (+ `nixfmt`). It runs as a plain subprocess under update.nix/nix-update in the
  user's environment (network + node + nix available), **not** inside a Nix build
  sandbox. Verified: running it against a forced `0.0.0 -> 2.13.0` regenerated both
  lockfiles **byte-identical** to the vendored ones and wrote the correct hashes.
- The `bun` npm dep is **stripped** from `package.json` + lockfile (its postinstall
  fails offline); it's unused at runtime because `OPENCODEX_BUN_PATH` (nixpkgs `bun`)
  takes precedence in the launcher.
- GUI `installPhase` overrides `buildNpmPackage`'s default (we only want `dist`).
- **Status: DONE.** Built, `ocx --version` → `opencodex 2.13.0`, bwrap-sandboxed
  `ocx start` served `/healthz` at version 2.13.0, GUI bundled. `versionCheckHook`
  passes at build time; `testers` was dropped (redundant). Update script tested.
  All changes staged (not committed). `nix flake check` only fails on a pre-existing
  devenv assertion unrelated to this package.
