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

    "@gotgenes/pi-permission-system" = mkScopedPackage "@gotgenes" "pi-permission-system" {
      version = "7.4.0";
      hash = "sha256-3UrQrIKpOwp7ihBaMEOxqBJQfkaEzjtZ+IDQRBqQ0w4=";
      npmDepsHash = "sha256-2j2GawLnOXl30aLWTAZxY7r5IqX52q97Px8gh8qXMRw=";
      description = "Permission system extension for Pi coding agent";
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

    # ── Messaging Extensions ─────────────────────────────────────────────────

    "@llblab/pi-telegram" = mkScopedPackage "@llblab" "pi-telegram" {
      version = "0.13.2";
      hash = "sha256-9vOwRiuqtQwxQOJWv7t17GNnLLT2CzBGMvP50T/jzR8=";
      npmDepsHash = "";  # No dependencies, only peer dependencies
      description = "Telegram integration for Pi coding agent";
      homepage = "https://github.com/llblab/pi-telegram";
    };

    "@tmustier/pi-usage-extension" = mkScopedPackage "@tmustier" "pi-usage-extension" {
      version = "0.3.2";
      hash = "sha256-9n3tNqsjMXBF3bGVEv2WKdezpXJOjHzw49KGKlCc7Pg=";
      npmDepsHash = "";  # No dependencies, only peer dependencies
      description = "Usage tracking extension for Pi coding agent";
      homepage = "https://github.com/tmustier/pi-usage-extension";
    };

    # ── Voice & TTS Extensions ──────────────────────────────────────────────────

    "@wenjinnn/pi-mimo-voice" = mkScopedPackage "@wenjinnn" "pi-mimo-voice" {
      version = "1.1.0";
      hash = "sha256-Dtjaqu7iGtyCuLz3wwnSnt8GZi216+8gOOjrFIgUm+k=";
      npmDepsHash = "";  # No dependencies, only peer dependencies
      description = "MiMo voice synthesis extension for Pi coding agent";
      homepage = "https://github.com/wenjinnn/pi-mimo-voice";
    };

    # ── Permission Extensions ──────────────────────────────────────────────────

    "pi-permission-system" = mkPackage "pi-permission-system" {
      version = "0.6.0";
      hash = "sha256-Vci3fxl/9xRzaM6wEKyFg4wmR+PXAzuwE6WYUj4Yfy0=";
      npmDepsHash = "sha256-cotzXcB8IqMUwZOjVnqmr6sUZj2KCG3njNcRIzUPj/g=";
      description = "Permission system extension for Pi coding agent";
      homepage = "https://github.com/MasuRii/pi-permission-system";
    };

    # ── WeChat Extensions ──────────────────────────────────────────────────────

    "pi-weixinbot" = mkPackage "pi-weixinbot" {
      version = "1.0.5";
      hash = "sha256-VXLAWvezKghW7ehTTXv6PPgUnqYYj+PXWYigasKtfpc=";
      npmDepsHash = "sha256-ZtNQEIY2FN2Xx6Ob8nE7FA8muNCFiW076kgBtg9EtSc=";
      description = "微信机器人 extension for pi，支持扫码登录和消息收发";
      homepage = "https://github.com/huang-x-h/pi-weixinbot";
    };

    "pi-subagents" = mkPackage "pi-subagents" {
      version = "0.27.0";
      hash = "sha256-c/DaUyyb3GJL5UpMUyFBmhx2bZWthXbF0UvMqm0BR7k=";
      npmDepsHash = "sha256-1d1/DcbHQr+XgV25i/Ai1k4F+Jc+2UbwCfw+bBQYrds=";
      description = "Pi extension for delegating tasks to subagents with chains, parallel execution, and TUI clarification";
      homepage = "https://github.com/nicobailon/pi-subagents";
    };

    "pi-interactive-shell" = mkPackage "pi-interactive-shell" {
      version = "0.13.0";
      hash = "sha256-MJWRamvoSy+qYxix/Oq5rHII3j1GbhCyb0u8ufBpgMY=";
      npmDepsHash = "sha256-2pmQsgdz014tH1AYjAv3Kd5jaDA85wBE7R+9God4LOs=";
      description = "Run AI coding agents in pi TUI overlays with interactive, hands-free, and dispatch supervision";
      homepage = "https://github.com/nicobailon/pi-interactive-shell";
    };

    "pi-intercom" = mkPackage "pi-intercom" {
      version = "0.6.0";
      hash = "sha256-dsDVKEZhqsQ3JIu2x6Moef6GMpa9FctTN1GyfK/ESBg=";
      npmDepsHash = "sha256-sQuiQbFL8FXFxe+hxJEPY9jc87KdpPqBCXd7b3MoLkU=";
      description = "Inter-session communication extension for pi coding agent";
      homepage = "https://github.com/nicobailon/pi-intercom";
    };

    "pi-caveman" = mkPackage "pi-caveman" {
      version = "1.0.7";
      hash = "sha256-uM65rViCdpOxZSVsQ88GADKvPS4zjaxW3vst4iHKuq4=";
      npmDepsHash = "";  # No dependencies
      description = "Caveman mode for pi - cuts ~75% output tokens while keeping full technical accuracy";
      homepage = "https://github.com/jonjonrankin/pi-caveman";
    };

    # ── Guardrails Extensions ────────────────────────────────────────────────

    "@aliou/pi-guardrails" = mkScopedPackage "@aliou" "pi-guardrails" {
      version = "0.13.1";
      hash = "sha256-W+fAMF2sHjB1CWrgsFaNNnREoXhdFCLrWup2ZyLcpkI=";
      npmDepsHash = "sha256-bz/xEfH6UX38v7oEbbkbqxo4+h/glYBgBQin0rlTGIQ=";
      description = "Guardrails extension for Pi coding agent";
      homepage = "https://github.com/aliou/pi-guardrails";
    };

    # ── Code Analysis Extensions ──────────────────────────────────────────────

    "pi-lens" = mkPackage "pi-lens" {
      version = "3.8.47";
      hash = "sha256-KI7LZ3gJynAoXq2McMthR4b0/6fGPAnhwpwhAbUkOUo=";
      npmDepsHash = "sha256-C/4wlBTIAT//q/ahXmV0DeRJe8FoIVoyXOSGqNzeNlA=";
      description = "Code lens and analysis extension for Pi coding agent";
      homepage = "https://pi.dev/packages/pi-lens";
    };

    # ── TODO: Add more packages ──────────────────────────────────────────────
    # Use the update script to get hashes:
    #   ./pkgs/pi-packages/scripts/update-pi-package.sh <package-name> [version]
  };
in
packages
