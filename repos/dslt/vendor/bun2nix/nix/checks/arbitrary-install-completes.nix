{ lib, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      checks.arbitraryInstallCompletes = pkgs.stdenv.mkDerivation {
        name = "bun2nix-exec-test";

        outputHash = "sha256-mYoND6xD+uEgKjq17hDWPe5pEEnwmSNfHPCqE4R+B5E=";
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";

        src = ./arbitrary-install-completes/test-project;

        nativeBuildInputs = with pkgs; [
          nix
          cacert
          git
          nixfmt
          gnutar
          gzip
        ];

        installPhase = ''
          PWD="$(pwd)"

          # Create local tarball for testing bun2nix's handling of local tarballs
          # without file: prefix (Bun strips it in the packages section).
          bash ./local-tarball/setup.sh

          export NIX_STATE_DIR=$PWD/nix-state
          export NIX_STORE_DIR=$PWD/nix-store
          export NIX_PROFILES_DIR=$PWD/nix-profiles
          export NIX_CONF_DIR=$PWD/nix-conf
          export HOME=$PWD/home
          mkdir -p $NIX_STATE_DIR $NIX_STORE_DIR $NIX_PROFILES_DIR $NIX_CONF_DIR $HOME

          bun_nix=$(${lib.getExe self'.packages.bun2nix})

          nix eval \
            --extra-experimental-features nix-command \
            --expr "$bun_nix"

          echo ${self'.packages.bun2nix.version} > "$out"

          if [ "$bun_nix" != "$(echo "$bun_nix" | nixfmt)" ]; then
            printf '\n\033[31mError:\033[0m %s\n\n' "bun2nix generated file should be nix formatted"
            exit 1
          fi
        '';
      };
    };
}
