{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; },
}:
{
  libs =
    (import ./libs {
      inherit system pkgs;
    })
    // (import ./libs/pure.nix {
      inherit nixpkgs;
      systems = [ system ];
    });

  bundlers = import ./bundlers {
    inherit system pkgs;
  };

  images = import ./images {
    inherit system pkgs;
  };

  modules = import ./modules { inherit nixpkgs; }; # NixOS modules
  overlays = import ./overlays { inherit nixpkgs; }; # nixpkgs overlays
}
// pkgs.lib.filterAttrs (_: pkg: if builtins.hasAttr "exclude" pkg then pkg.exclude else true) (
  import ./packages {
    inherit system pkgs;
  }
)
