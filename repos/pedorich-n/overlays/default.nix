{
  default =
    _final: prev:
    let
      reserved = import ../reserved-names.nix;
      overlayAttrs = import ../default.nix { pkgs = prev; };
    in
    removeAttrs overlayAttrs reserved;
}
