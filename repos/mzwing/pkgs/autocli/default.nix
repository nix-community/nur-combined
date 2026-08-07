{
  lib,
  stdenv,
  pkgs,
  source,
  installShellFiles,
  makeWrapper,
  which,
  procps,
  lsof,
  xdg-utils,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  cargoNixPath = ./Cargo.nix;

  # Workspace members, derived from the generated Cargo.nix itself so this
  # list tracks upstream automatically when the update script regenerates
  # the file. This first import only reads the attribute names of
  # workspaceMembers; evaluation is lazy, so no crate source is forced.
  workspaceCrates = builtins.attrNames (import cargoNixPath {inherit pkgs;}).workspaceMembers;

  # Most members live in crates/<crate name>; exceptions only:
  memberDirs = {
    # crates/autocli-cli contains the "autocli" binary crate.
    autocli = "crates/autocli-cli";
  };

  # ./Cargo.nix (next to this file) is generated with `crate2nix generate`
  # at the upstream source root by the update script
  # (scripts/package-updates) and committed to this repository. Building it
  # needs no crate2nix at evaluation or build time, only nixpkgs'
  # buildRustCrate.
  cargoNix = import cargoNixPath {
    inherit pkgs;
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // lib.genAttrs workspaceCrates (
        name: attrs: {
          # Build every member from the full source tree (buildRustCrate
          # cds into `workspace_member` during configure). The generated
          # per-member ./crates/<dir> paths do not exist in this
          # repository and are never forced once src is overridden here.
          src = source.src;
          workspace_member = memberDirs.${name} or "crates/${name}";
        }
      );
  };

  autocli = cargoNix.workspaceMembers.autocli.build;
in
  autocli.overrideAttrs (old: {
    # crate2nix names the derivation rust_autocli-<crate version>.
    name = "${pname}-${version}";

    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ [installShellFiles]
      ++ lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

    postInstall = ''
      installShellCompletion --cmd autocli \
        --bash <($out/bin/autocli completion bash) \
        --zsh <($out/bin/autocli completion zsh) \
        --fish <($out/bin/autocli completion fish)

      install -Dm644 ${src}/LICENSE ${src}/NOTICE -t $out/share/doc/autocli
    '';

    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/autocli \
        --prefix PATH : ${
        lib.makeBinPath [
          which
          procps
          lsof
          xdg-utils
        ]
      }
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/autocli --version | grep -F '${version}'
      $out/bin/autocli --help >/dev/null
      $out/bin/autocli hackernews --help >/dev/null

      test -f $out/share/bash-completion/completions/autocli.bash
      test -f $out/share/zsh/site-functions/_autocli
      test -f $out/share/fish/vendor_completions.d/autocli.fish
      test -f $out/share/doc/autocli/LICENSE
      test -f $out/share/doc/autocli/NOTICE

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "AutoCLI is a Blazing fast, memory-safe command-line tool — Fetch information from any website with a single command. Covers Twitter/X, Reddit, YouTube, HackerNews, Bilibili, Zhihu, Xiaohongshu, and 55+ sites, with support for controlling Electron desktop apps, integrating local CLI tools (gh, docker, kubectl), now powered by AutoCLI.ai";
        homepage = "https://github.com/nashsu/AutoCLI";
        changelog = "https://github.com/nashsu/AutoCLI/releases/tag/v${version}";
        license = lib.licenses.asl20;
        mainProgram = "autocli";
        maintainers = [
          {
            name = "mzwing";
          }
        ];
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
      };
  })
