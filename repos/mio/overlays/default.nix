rec {
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;
  default =
    final: prev:
    import ../packages.nix { pkgs = prev; }
    // {
      mio = import ../default.nix { pkgs = prev; };
    };
  howdy =
    final: prev:
    let
      pkgs = default final prev;
    in
    {
      inherit (pkgs) howdy linux-enable-ir-emitter;
    };
}
