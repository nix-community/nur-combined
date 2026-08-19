{
  lib,
  pkgs,
  source,
  rustfmt,
}: let
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  # Read workspace members lazily from the generated Cargo.nix.
  workspaceCrates =
    builtins.attrNames (import ./Cargo.nix {inherit pkgs;}).workspaceMembers;

  # Use the committed crate2nix graph; builds only need nixpkgs' buildRustCrate.
  crateOverrides =
    pkgs.defaultCrateOverrides
    // lib.genAttrs workspaceCrates (name: attrs: {
      # Build each member from the fetched workspace, including the plugin WIT submodule.
      src = source.src;
      workspace_member = "crates/${name}";
      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [rustfmt];
    });

  cargoNix = import ./Cargo.nix {
    inherit pkgs;
    # Match Cargo's 16 release codegen units for faster builds.
    buildRustCrateForPkgs = pkgs: pkgs.buildRustCrate.override {defaultCodegenUnits = 16;};
    defaultCrateOverrides = crateOverrides;
  };

  pumpkin = cargoNix.workspaceMembers.pumpkin.build;
in
  pumpkin.overrideAttrs (old: {
    # Replace the crate2nix derivation name.
    name = "${pname}-${version}";

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
