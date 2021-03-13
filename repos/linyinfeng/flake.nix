{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mkApp = drvName: cfg: flake-utils.lib.mkApp ({ drv = self.packages.${system}.${drvName}; } // cfg);
      in
      {
        packages = import ./pkgs { inherit pkgs; };
        apps = {
          activate-dpt = mkApp "activate-dpt" { };
          clash-premium = mkApp "clash-premium" { name = "clash"; };
          dpt-rp1-py = mkApp "dpt-rp1-py" { name = "dptrp1"; };
          godns = mkApp "godns" { };
          musicbox = mkApp "musicbox" { };
          trojan = mkApp "trojan" { };
          vlmcsd = mkApp "vlmcsd" { };
        };
      })) //
    {
      lib = import ./lib { inherit (nixpkgs) lib; };
      nixosModules = import ./modules;
      overlays = import ./overlays;
    };
}
