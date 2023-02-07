{ self }:
let
  fn = { pkgs, ... }:
    let
      inherit (self.inputs) home-manager;
      inherit (pkgs.stdenv) isLinux;

      base = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };

    in if isLinux then [
      base
      home-manager.nixosModules.home-manager
    ] else [
      base
      home-manager.darwinModule
    ];
in fn
