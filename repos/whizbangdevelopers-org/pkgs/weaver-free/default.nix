# Weaver Free tier only — AGPL-3.0 licensed.
#
# LICENSING GATE: Weaver Solo / Team / Fabrick are BSL-1.1 (Business Source
# License) and distributed through commercial channels. They are NEVER
# eligible for NUR publication. The `fetchFromGitHub` target below fetches
# from Weaver-Free — the AGPL-3.0 public mirror maintained by the upstream
# sync workflow. All paid-tier code paths are structurally excluded from
# Weaver-Free via .github/sync-exclude.yml in whizbangdevelopers-org/Weaver-Dev.
#
# Do NOT change `repo` to `Weaver-Dev` or any private/paid-tier repository.
# Doing so would publish BSL-1.1 commercial code to a public community
# repository in violation of the license.
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  bash,
}:

buildNpmPackage rec {
  pname = "weaver-free";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "whizbangdevelopers-org";
    repo = "Weaver-Free";
    rev = "v${version}";
    # Populated by .github/workflows/update-weaver.yml on weaver-release dispatch.
    hash = "sha256-feQB1CUOL6ei3ZO0bhub1ag2Sqv+Ny/3Y10vLgYSYwE=";
  };

  # Single hash covers all workspace deps (root + backend + tui) — Weaver uses npm workspaces.
  # Populated by the update workflow; matches code/nixos/package.nix in the dev repo.
  npmDepsHash = "sha256-Fm+NfFiCrNW6rxYg1Sy12p/Mxl02uZ+I6jTnuWFm85c=";

  makeCacheWritable = true;
  nodejs = nodejs_24;

  buildPhase = ''
    # Remove sass-embedded (ships pre-built dart binary that fails in Nix sandbox).
    # Vite falls back to pure-JS "sass" package which is already installed.
    rm -rf node_modules/sass-embedded node_modules/sass-embedded-*

    # Build backend (workspace — deps already installed by npmConfigHook)
    pushd backend
    patchShebangs node_modules 2>/dev/null || true
    npm run build
    popd

    # Build TUI (workspace)
    pushd tui
    patchShebangs node_modules 2>/dev/null || true
    npm run build
    popd

    # Build frontend PWA
    # VITE_FREE_BUILD=true tells routes.ts to tree-shake paid-tier route
    # imports (pages/fabrick/*, pages/funnel/*) which are sync-excluded.
    # Without this, rolldown tries to resolve them and fails.
    export VITE_FREE_BUILD=true
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/lib/weaver/backend
    mkdir -p $out/lib/weaver/frontend
    mkdir -p $out/lib/weaver/tui

    # Backend
    cp -r backend/dist/* $out/lib/weaver/backend/
    cp backend/package.json $out/lib/weaver/backend/

    # Frontend PWA
    cp -r dist/pwa/* $out/lib/weaver/frontend/

    # TUI
    cp -r tui/dist/* $out/lib/weaver/tui/
    cp tui/package.json $out/lib/weaver/tui/

    # Operator-facing docs — UPGRADE.md is accessible from a shell when the
    # service is down (the scenario where users need it most). ADMIN and USER
    # guides also shipped so a shell user can `cat` them during recovery.
    mkdir -p $out/lib/weaver/docs
    cp docs/UPGRADE.md $out/lib/weaver/docs/
    cp docs/ADMIN-GUIDE.md $out/lib/weaver/docs/
    cp docs/USER-GUIDE.md $out/lib/weaver/docs/

    # Shared node_modules (workspaces hoist — one tree serves all three)
    cp -r node_modules $out/lib/weaver/

    # Launcher
    mkdir -p $out/bin
    cat > $out/bin/weaver << LAUNCHER
    #!${bash}/bin/bash
    export STATIC_DIR="\''${STATIC_DIR:-$out/lib/weaver/frontend}"
    exec ${nodejs_24}/bin/node "$out/lib/weaver/backend/index.js" "\$@"
    LAUNCHER
    chmod +x $out/bin/weaver
  '';

  meta = {
    description = "NixOS workload isolation — unified container and MicroVM management";
    homepage = "https://github.com/whizbangdevelopers-org/Weaver-Free";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "weaver";
  };
}
