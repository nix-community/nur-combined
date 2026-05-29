# piPackages - Nix package set for pi coding agent packages
# Uses buildNpmPackage for packages with dependencies
{
  pkgs,
  lib,
}:

let
  mkNodePackage = import ./mkNodePackage.nix { inherit pkgs lib; };
  locksDir = ./locks;

  # Helper for scoped packages
  mkScopedPackage = scope: name: args: mkNodePackage (args // {
    inherit scope name;
    packageLockJson = locksDir + "/${lib.replaceStrings [ "@" "/" ] [ "-" "-" ] "${scope}/${name}"}-${args.version}.json";
  });

  # Helper for unscoped packages
  mkPackage = name: args: mkNodePackage (args // {
    inherit name;
    packageLockJson = locksDir + "/${name}-${args.version}.json";
  });

  packages = {
    # ── Core Extensions ──────────────────────────────────────────────────────

    "pi-mcp-adapter" = mkPackage "pi-mcp-adapter" {
      version = "2.8.0";
      hash = "sha256-kSjvMGShpuRb+ImdzY9PPbIAZahOTtA+SoOlPLTvg2w=";
      npmDepsHash = "sha256-qQXM2KFdzBTXrKzyYzYxMs7uRSHwUSmHj9zl/Srf2hc=";
      description = "MCP (Model Context Protocol) adapter extension for Pi coding agent";
      homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    };

    "pi-web-access" = mkPackage "pi-web-access" {
      version = "0.10.7";
      hash = "sha256-v0CQxc2TySwdlGYCha3cazQpMgHQCaipjGVpW49H2Pk=";
      npmDepsHash = "sha256-p+pLopNZ+8H3so2iZ0Rtrn1ndt61Vp1uChGGjUuPrWY=";
      description = "Web search, URL fetching, GitHub repo cloning, PDF extraction for Pi";
      homepage = "https://github.com/nicobailon/pi-web-access";
    };

    "pi-hermes-memory" = mkPackage "pi-hermes-memory" {
      version = "0.7.13";
      hash = "sha256-B9A1rjiUZRuZh+cyPe3cwchzc6Av72pEjFvzrawAr+E=";
      npmDepsHash = "sha256-Ba9GSwrSCRiE31lR17NUYcRnFkzeEUhSFHOZSF85Ntg=";
      description = "Persistent memory + session search + secret scanning for Pi";
      homepage = "https://github.com/chandra447/pi-hermes-memory";
    };

    # ── Subagent Extensions ──────────────────────────────────────────────────

    "@gotgenes/pi-subagents" = mkScopedPackage "@gotgenes" "pi-subagents" {
      version = "11.3.0";
      hash = "sha256-W5JbjSujHTUwo5RT+sd9WZDug/Oc/hatbhU582LnGXQ=";
      npmDepsHash = "sha256-BTOcb/KeNK4XF+BmfSxlDuuQMo5JlBg0ffjdOTUi8p0=";
      description = "Claude Code-style autonomous sub-agents for pi";
      homepage = "https://github.com/gotgenes/pi-packages";
    };

    "@junghanacs/pi-shell-acp" = mkScopedPackage "@junghanacs" "pi-shell-acp" {
      version = "0.7.6";
      hash = "sha256-Tuy8DZQFTA7a+wjDZbKFze1ZUFfZOAKiEitdWcVh+kw=";
      npmDepsHash = "sha256-b+BjB8FqcTNEUoaNK/+XhP/ApLWcZryEcoFXLA/ttME=";
      description = "Pi shell ACP integration";
      homepage = "https://www.npmjs.com/package/@junghanacs/pi-shell-acp";
    };

    # ── Workflow Extensions ──────────────────────────────────────────────────

    "@juicesharp/rpiv-ask-user-question" = mkScopedPackage "@juicesharp" "rpiv-ask-user-question" {
      version = "1.15.0";
      hash = "sha256-GY/huRdtomArCbMPlXjfi1ytqLSTebXzABsshEnhyYM=";
      npmDepsHash = "sha256-F38whcTwDajModvv9nRU1SdovZt5HXmlJXS0rlvHvMI=";
      description = "Structured questionnaire the model can put to you";
      homepage = "https://github.com/juicesharp/rpiv-mono";
    };

    "@juicesharp/rpiv-btw" = mkScopedPackage "@juicesharp" "rpiv-btw" {
      version = "1.15.0";
      hash = "sha256-XzrGxF05bNyBFjMDOp5ILD4yadXLlsTOECvpucUpS/g=";
      npmDepsHash = "";  # No dependencies
      description = "The /btw slash command for side questions";
      homepage = "https://github.com/juicesharp/rpiv-mono";
    };

    "@juicesharp/rpiv-todo" = mkScopedPackage "@juicesharp" "rpiv-todo" {
      version = "1.15.0";
      hash = "sha256-LHfWoEzjl4kxbM8HcPPjmqwxQmZ+ILrow6IEtl5KeV0=";
      npmDepsHash = "sha256-djLJ3FO5W3GQzOyXEk36A0jW/wMls6YjRFJn12cv1/s=";
      description = "A todo list for the model, rendered as a live overlay that survives /reload and conversation compaction";
      homepage = "https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo";
    };

    # ── Plan Review Extensions ──────────────────────────────────────────────

    "@plannotator/pi-extension" = mkScopedPackage "@plannotator" "pi-extension" {
      version = "0.19.24";
      hash = "sha256-+Ebc3flG53Mt6nvQqJrt3lGSTFwIW5nBaLSSdtL0Y1M=";
      npmDepsHash = "sha256-0pC+ZNiCt0ibPTtQgySVdV+v3nUTPVO+ck+ZgF9QuF0=";
      description = "Plannotator Pi extension - interactive plan review with annotations, annotate agent messages, and review code/PRs";
      homepage = "https://github.com/backnotprop/plannotator";
      license = pkgs.lib.licenses.mit;  # MIT OR Apache-2.0
    };

    # ── TODO: Add more packages ──────────────────────────────────────────────
    # Use the update script to get hashes:
    #   ./pkgs/pi-packages/scripts/update-pi-package.sh <package-name> [version]
  };
in
packages
