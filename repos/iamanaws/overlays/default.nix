{ nur }:

let
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    t3code = prev.t3code.override {
      t3code-unwrapped = final.callPackage "${
        final.applyPatches {
          name = "t3code-0.0.37-source";
          src = "${prev.path}/pkgs/by-name/t3/t3code";
          patches = [
            (final.fetchpatch2 {
              url = "https://github.com/NixOS/nixpkgs/pull/556674.patch?full_index=1";
              hash = "sha256-hx0FoNHX0TntnvyuJCXFlmqmTjBXNz+SkrLOo50aZKc=";
            })
            (final.fetchpatch2 {
              url = "https://github.com/NixOS/nixpkgs/pull/558233.patch?full_index=1";
              hash = "sha256-JVwVJ6L7rBKDkyk6fUT3fZqp04MxPWV4bGx1B/CcBNQ=";
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
