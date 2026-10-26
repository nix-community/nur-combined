rec {
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;
  default =
    final: prev:
    let
      packages = import ../packages.nix { pkgs = prev; };
    in
    packages
    // {
      jetbrains = (prev.jetbrains or { }) // {
        idea-oss = packages.jetbrains_idea-oss;
      };
      mio = import ../default.nix { pkgs = prev; };
    };
}
