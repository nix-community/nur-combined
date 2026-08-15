{
  lib,
  pkgs,
  source,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # ./Cargo.nix (next to this file) is generated with `crate2nix generate`
  # at the upstream source root by the update script
  # (scripts/package-updates) and committed to this repository. Building it
  # needs no crate2nix at evaluation or build time, only nixpkgs'
  # buildRustCrate.
  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    # nixpkgs' buildRustCrate defaults to -C codegen-units=1 (crate2nix
    # does not propagate the workspace profile), which serialises LLVM
    # codegen per crate; the WebRTC/Slint crates in this graph then need
    # 5+ hours each — beyond the 6-hour CI job limit, so they can never
    # finish. 16 units matches Cargo's own release default.
    buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate.override { defaultCodegenUnits = 16; };
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        wsrx = attrs: {
          # The generated file points the member's src at ./crates/wsrx
          # relative to the committed Cargo.nix, which does not exist in
          # this repository; that path thunk is never forced once src is
          # overridden here. Every member builds from the full source tree
          # (buildRustCrate cds into `workspace_member` during configure).
          src = source.src;
          workspace_member = "crates/wsrx";
        };
      };
  };

  wsrxCli = cargoNix.workspaceMembers.wsrx.build;
in
  wsrxCli.overrideAttrs (old: {
    # crate2nix names the derivation rust_wsrx-<crate version>.
    name = "${pname}-${version}";

    postInstall = ''
      install -Dm644 \
        ${src}/LICENSE \
        ${src}/README.md \
        -t $out/share/doc/wsrx
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/wsrx --version | grep -F '${version}'
      $out/bin/wsrx --help >/dev/null
      test -f $out/share/doc/wsrx/LICENSE
      test -f $out/share/doc/wsrx/README.md

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "Controlled TCP-over-WebSocket forwarding tunnel";
        homepage = "https://github.com/XDSEC/WebSocketReflectorX";
        changelog = "https://github.com/XDSEC/WebSocketReflectorX/releases/tag/${version}";
        license = lib.licenses.mit;
        mainProgram = "wsrx";
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
