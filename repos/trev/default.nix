{
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; },
}:
{
  libs =
    import ./libs {
      inherit system pkgs;
    }
    // import ./libs/pure.nix {
      inherit nixpkgs;
      systems = [ system ];
    };

  bundlers = import ./bundlers {
    inherit system pkgs;
  };

  images = import ./images {
    inherit system pkgs;
  };

  modules = import ./modules {
    inherit nixpkgs;
  };

  overlays = import ./overlays {
    inherit nixpkgs;
  };
}
// import ./packages {
  inherit system pkgs;
}
