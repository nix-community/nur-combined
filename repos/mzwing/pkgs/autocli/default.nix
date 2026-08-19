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

  # Read workspace members lazily from the generated Cargo.nix.
  workspaceCrates = builtins.attrNames (import cargoNixPath {inherit pkgs;}).workspaceMembers;

  # Workspace directory exceptions.
  memberDirs = {
    # The `autocli` crate lives in autocli-cli.
    autocli = "crates/autocli-cli";
  };

  # Use the committed crate2nix graph; builds only need nixpkgs' buildRustCrate.
  cargoNix = import cargoNixPath {
    inherit pkgs;
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // lib.genAttrs workspaceCrates (
        name: attrs: {
          # Build each member from the fetched workspace root.
          src = source.src;
          workspace_member = memberDirs.${name} or "crates/${name}";
        }
      );
  };

  autocli = cargoNix.workspaceMembers.autocli.build;
in
  autocli.overrideAttrs (old: {
    # Replace the crate2nix derivation name.
    name = "${pname}-${version}";

    # Collapse this bin-only leaf crate to one output to avoid a reference cycle.
    outputs = ["out"];
    # Keep buildRustCrate's development output on the remaining output.
    outputDev = ["out"];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp -rP target/bin/* $out/bin/
      runHook postInstall
    '';

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
