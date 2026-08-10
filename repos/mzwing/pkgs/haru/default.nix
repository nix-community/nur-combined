{
  lib,
  pkgs,
  # Nullable (like pkgs/codegraph) so the whole package set keeps
  # evaluating between the commit that adds this package and the
  # follow-up "Update packages" action commit that adds the `haru`
  # entry to _sources/generated.nix.
  source ? null,
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
    defaultCrateOverrides =
      pkgs.defaultCrateOverrides
      // {
        # The crate name is haru-cat; the binary it installs is haru.
        haru-cat = attrs: {
          # The generated file points src at ./. relative to the committed
          # Cargo.nix, which is not the crate source; that path thunk is
          # never forced once src is overridden here. Single-crate project:
          # the crate root is the source root, so no workspace_member.
          src = source.src;
        };
      };
  };

  haru = cargoNix.rootCrate.build;
in
  if source == null
  then null
  else
    haru.overrideAttrs (old: {
      # crate2nix names the derivation rust_haru-cat-<crate version>.
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
