{ sources ? import ./sources.nix
, unstable ? import sources.nixpkgs-unstable {}
}:

let
  # use unstable version of packages
  overlay = selfpkgs: superpkgs:
    { 
      lefthook = unstable.lefthook;
    };

  nixpkgs = import sources.nixpkgs-stable
    { 
      overlays = [ overlay ];
      config = {};
    };
in
  nixpkgs

