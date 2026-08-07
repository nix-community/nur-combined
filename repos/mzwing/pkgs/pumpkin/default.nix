{
  lib,
  pkgs,
  source,
  rustfmt,
}: let
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  # Workspace members, derived from the generated Cargo.nix itself so this
  # list tracks upstream automatically when the update script regenerates
  # the file. This first import only reads the attribute names of
  # workspaceMembers; evaluation is lazy, so no crate source (and in
  # particular none of the ./crates/<name> path thunks, which do not exist
  # in this repository) is forced.
  workspaceCrates =
    builtins.attrNames (import ../../_sources/pkgs/pumpkin/Cargo.nix {inherit pkgs;}).workspaceMembers;

  # _sources/pkgs/pumpkin/Cargo.nix is generated with `crate2nix generate`
  # at the upstream source root by the update script
  # (scripts/package-updates) and committed to this repository. Building it
  # needs no crate2nix at evaluation or build time, only nixpkgs'
  # buildRustCrate.
  cargoNix = import ../../_sources/pkgs/pumpkin/Cargo.nix {
    inherit pkgs;
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // lib.genAttrs workspaceCrates (name: attrs: {
        # The generated file points each member's src at ./crates/<name>
        # relative to the committed Cargo.nix, which does not exist in this
        # repository. Those path thunks are never forced once src is
        # overridden here. Every member builds from the full source tree
        # (buildRustCrate cds into `workspace_member` during configure),
        # which also makes pumpkin-plugin-api's compile-time include of
        # ../pumpkin-plugin-wit/v0.1 (a git submodule) work.
        src = source.src;
        workspace_member = "crates/${name}";
        nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [rustfmt];
      });
  };

  pumpkin = cargoNix.workspaceMembers.pumpkin.build;

  # Test variant of the main crate (builds with dev-dependencies and runs
  # the test binaries). Scope is deliberately limited to the pumpkin crate
  # itself; the other workspace members' tests are left to upstream CI.
  tests = pumpkin.override {runTests = true;};
in
  pumpkin.overrideAttrs (old: {
    # crate2nix names the derivation rust_pumpkin-<crate version>.
    name = "${pname}-${version}";

    # Gate the build on the test suite: interpolating the test derivation
    # forces it to build (and thus pass) before the install phase runs.
    preInstall = ''
      echo "pumpkin test suite passed: ${tests}"
    '';

    postInstall = ''
      install -Dm644 ${src}/LICENSE ${src}/README.md -t $out/share/doc/pumpkin
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test -x $out/bin/pumpkin
      test -f $out/share/doc/pumpkin/LICENSE
      test -f $out/share/doc/pumpkin/README.md

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "Empowering everyone to host fast and efficient Minecraft servers";
        homepage = "https://github.com/Pumpkin-MC/Pumpkin";
        license = lib.licenses.gpl3Only;
        mainProgram = "pumpkin";
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
