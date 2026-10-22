{
  default =
    final: _prev:
    let
      kernels = import ../pkgs { pkgs = final; };
    in
    kernels
    // import ../lib/cachyos/package-sets.nix {
      pkgs = final;
      inherit kernels;
    }
    // {
      # Compatibility alias; CI and update automation use the canonical name.
      rimsort = final.rimsort-appimage;
    };
}
