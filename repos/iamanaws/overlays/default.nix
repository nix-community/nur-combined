{ nur }:

let
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # https://github.com/NixOS/nixpkgs/pull/549253
    # glaze 8.0.0 broke hyprland's find_package(glaze 7...<8), which then
    # falls back to FetchContent/git clone and fails in the nix sandbox.
    hyprland = prev.hyprland.overrideAttrs (old: {
      postPatch =
        ''
          # Relax glaze dependency
          # FIXME: this shouldn't be needed once the upstream code will adopt it
          substituteInPlace CMakeLists.txt start/CMakeLists.txt hyprpm/CMakeLists.txt \
            --replace-fail "glaze 7...<8" "glaze"
        ''
        + (old.postPatch or "");
    });
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
