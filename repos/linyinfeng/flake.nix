{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        mkApp = drvName: cfg: flake-utils.lib.mkApp ({ drv = self.packages.${system}.${drvName}; } // cfg);
      in
      {
        packages = import ./pkgs { inherit pkgs; };
        apps = {
          activate-dpt = mkApp "activate-dpt" { };
          clash-premium = mkApp "clash-premium" { };
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
      overlays = {
        singleRepoNur = final: prev: {
          nur.repos.linyinfeng = self.packages.${final.system};
        };
      } // import ./overlays;
    };
}
