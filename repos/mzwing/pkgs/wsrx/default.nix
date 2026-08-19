{
  lib,
  pkgs,
  source,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Use the committed crate2nix graph; builds only need nixpkgs' buildRustCrate.
  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    # Match Cargo's 16 release codegen units to keep CI builds within the job limit.
    buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate.override {defaultCodegenUnits = 16;};
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        wsrx = attrs: {
          # Build the member from the fetched workspace root.
          src = source.src;
          workspace_member = "crates/wsrx";
        };
      };
  };

  wsrxCli = cargoNix.workspaceMembers.wsrx.build;
in
  wsrxCli.overrideAttrs (old: {
    # Replace the crate2nix derivation name.
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
