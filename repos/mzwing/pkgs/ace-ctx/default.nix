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

  # _sources/pkgs/ace-ctx/Cargo.nix is generated with `crate2nix generate`
  # at the upstream source root by the update script
  # (scripts/package-updates) and committed to this repository. Building it
  # needs no crate2nix at evaluation or build time, only nixpkgs'
  # buildRustCrate.
  cargoNix = import ../../_sources/pkgs/ace-ctx/Cargo.nix {
    inherit pkgs;
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        ace-ctx = attrs: {
          # The generated file points src at ./. relative to the committed
          # Cargo.nix, which is not the crate source; that path thunk is
          # never forced once src is overridden here. Single-crate project:
          # the crate root is the source root, so no workspace_member.
          src = source.src;
        };
      };
  };

  ace-ctx = cargoNix.rootCrate.build;

  # Test variant of the crate (builds with dev-dependencies and runs the
  # test binaries). The crate has no optional features, so the old
  # `cargo test --all-features` is equivalent to the default feature set.
  tests = ace-ctx.override {runTests = true;};
in
  ace-ctx.overrideAttrs (old: {
    # crate2nix names the derivation rust_ace-ctx-<crate version>.
    name = "${pname}-${version}";

    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

    # Gate the build on the test suite: interpolating the test derivation
    # forces it to build (and thus pass) before the install phase runs.
    preInstall = ''
      echo "ace-ctx test suite passed: ${tests}"
    '';

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
