{
  lib,
  stdenv,
  pkgs,
  source,
  makeWrapper,
  xdg-utils,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Use the committed crate2nix graph; builds only need nixpkgs' buildRustCrate.
  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        ace-ctx = attrs: {
          # Build the single crate from the fetched source root.
          src = source.src;
        };
      };
  };

  ace-ctx = cargoNix.rootCrate.build;
in
  ace-ctx.overrideAttrs (old: {
    # Replace the crate2nix derivation name.
    name = "${pname}-${version}";

    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

    postInstall = ''
      install -Dm644 \
        ${src}/LICENSE \
        ${src}/LICENSE-COMMERCIAL \
        ${src}/README.md \
        ${src}/README-zh-CN.md \
        -t $out/share/doc/ace-ctx
      install -Dm644 ${src}/docs/*.md -t $out/share/doc/ace-ctx/docs
    '';

    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/ace-ctx \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]}
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/ace-ctx --version | grep -F '${version}'
      $out/bin/ace-ctx --help >/dev/null
      test -f $out/share/doc/ace-ctx/LICENSE
      test -f $out/share/doc/ace-ctx/LICENSE-COMMERCIAL

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "Rust implementation of a codebase context engine that enables AI assistants to search and understand codebases using natural language queries";
        homepage = "https://github.com/CodingOX/ace-ctx";
        changelog = "https://github.com/CodingOX/ace-ctx/releases/tag/v${version}";
        license = lib.licenses.gpl3Only;
        mainProgram = "ace-ctx";
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
