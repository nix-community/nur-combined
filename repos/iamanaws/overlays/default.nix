{ nur }:

let
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Qt 6.12's uic rejects the templated `AddressableItemList<>` class name in
    # the .ui files; drop once https://github.com/rizinorg/cutter/pull/3670 lands
    # in a nixpkgs cutter release (https://github.com/NixOS/nixpkgs/issues/576576).
    cutter = prev.cutter.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [
        (final.fetchpatch2 {
          url = "https://github.com/rizinorg/cutter/commit/bfb65782c0b3e4df4e2f0e4f5284c51848bb8358.patch?full_index=1";
          hash = "sha256-JiJdsleg+tJrRMMQA6EEGM354HCb+dQDeImfr/MYUpc=";
        })
      ];
    });

    t3code = prev.t3code.override {
      t3code-unwrapped = final.callPackage "${
        final.applyPatches {
          name = "t3code-0.1.2-source-v3";
          src = "${prev.path}/pkgs/by-name/t3/t3code";
          patches = [
            (final.fetchpatch2 {
              url = "https://github.com/NixOS/nixpkgs/pull/575686.patch?full_index=1";
              hash = "sha256-qWaJUXb1y5C4gcp5E303HMTRMY8dQFuVcD3+l0NwSX0=";
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
