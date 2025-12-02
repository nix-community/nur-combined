{
  # Add your overlays here
  #
  # my-overlay = import ./my-overlay;
  default =
    final: prev:
    let
      mio = import ../default.nix { pkgs = prev; };
    in
    {
      inherit (mio) linux-enable-ir-emitter howdy;
    };
}
