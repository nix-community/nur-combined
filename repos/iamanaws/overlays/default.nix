{ nur }:

let
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    aseprite = final.callPackage "${
      final.applyPatches {
        name = "aseprite-1.3.18.2-source";
        src = "${prev.path}/pkgs/by-name/as/aseprite";
        patches = [
          (final.fetchpatch2 {
            url = "https://github.com/NixOS/nixpkgs/pull/552085.patch?full_index=1";
            hash = "sha256-TOKObZ0GJr7pGMIs+jdKt6lGPHxC1g/bwyT3CpI23Ho=";
          })
        ];
        patchFlags = [ "-p5" ];
      }
    }/package.nix" { };

    t3code = prev.t3code.override {
      t3code-unwrapped = final.callPackage "${
        final.applyPatches {
          name = "t3code-0.0.33-source";
          src = "${prev.path}/pkgs/by-name/t3/t3code";
          patches = [
            (final.fetchpatch2 {
              url = "https://github.com/NixOS/nixpkgs/pull/552082.patch?full_index=1";
              hash = "sha256-1/L1zf1cmQHeNuafV3fIRfHV9txkqhV9+Yv76pYCU3Y=";
            })
          ];
          patchFlags = [ "-p5" ];
        }
      }/unwrapped.nix" { };
    };
  };

  # This one brings our custom packages from the 'pkgs' directory and makes
  # them available through both NUR repository paths.
  additions =
    final: prev:
    let
      repoOverrides.iamanaws = import ../pkgs { pkgs = final; };
    in
    repoOverrides.iamanaws
    // {
      nur =
        import nur {
          pkgs = final;
          nurpkgs = prev;
          inherit repoOverrides;
        }
        // repoOverrides;
    };
in
{
  inherit additions modifications;
  nur = final: prev: { inherit (additions final prev) nur; };
  default = final: prev: additions final prev // modifications final prev;
}
