_: {
  perSystem =
    { pkgs, config, ... }:
    let
      # A minimal source tree containing the file the patch will rewrite.
      fixture = pkgs.runCommand "bun2nix-patches-fixture" { } ''
        mkdir -p $out
        printf 'before\n' > $out/marker.txt
      '';

      flipMarker = pkgs.writeText "flip-marker.patch" ''
        --- a/marker.txt
        +++ b/marker.txt
        @@ -1 +1 @@
        -before
        +after
      '';
    in
    {
      # Regression check for the standard nixpkgs `patches` attribute being
      # silently dropped when a derivation uses `bun2nix.hook`.
      checks.bunPatchPhaseHonorsPatchesAttribute = pkgs.stdenv.mkDerivation {
        name = "bun2nix-bunPatchPhase-honors-patches";

        src = fixture;
        patches = [ flipMarker ];

        nativeBuildInputs = [ config.mkDerivation.hook ];

        phases = [
          "unpackPhase"
          "patchPhase"
          "installPhase"
        ];

        installPhase = ''
          runHook preInstall

          got=$(cat marker.txt)
          if [[ "$got" != "after" ]]; then
            printf '\n\033[31mError:\033[0m bun2nix.hook dropped $patches.\n' >&2
            printf '  got:  %s\n  want: after\n' "$got" >&2
            exit 1
          fi

          mkdir -p "$out"
          cp marker.txt "$out/marker.txt"

          runHook postInstall
        '';
      };
    };
}
