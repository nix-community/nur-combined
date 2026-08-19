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
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        # The `haru-cat` crate installs `haru`.
        haru-cat = attrs: {
          # Build the single crate from the fetched source root.
          src = source.src;
        };
      };
  };

  haru = cargoNix.rootCrate.build;
in
  haru.overrideAttrs (old: {
    # Replace the crate2nix derivation name.
    name = "${pname}-${version}";

    postInstall = ''
      install -Dm644 \
        ${src}/LICENSE \
        ${src}/README.md \
        -t $out/share/doc/haru
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      $out/bin/haru --version | grep -F '${version}'
      $out/bin/haru --help >/dev/null
      test -f $out/share/doc/haru/LICENSE
      test -f $out/share/doc/haru/README.md

      runHook postInstallCheck
    '';

    meta =
      old.meta
      // {
        description = "A tiny cat living in your terminal";
        homepage = "https://github.com/HyacinthHaru/haru";
        changelog = "https://github.com/HyacinthHaru/haru/releases/tag/v${version}";
        license = lib.licenses.mit;
        mainProgram = "haru";
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
