{
  description = "lihaoze123's NUR packages";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  inputs.dms-xhup = {
    url = "github:lihaoze123/dms-xhup/3323ff83dcf34f569f9c433234a2d20e3c0daec1";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.computer-use.url = "github:lihaoze123/niri-computer-use/0683aa6b0f16812abc0bc11f7e5a9d3a578522ef";
  inputs.edunet.url = "github:lihaoze123/hhu-edunet-cli/cd4b7d4d12be160fc8c1aee777adf60267b759a7";
  inputs.gxfp5130Chicago = {
    url = "github:lihaoze123/gxfp5130-chicago/fa78a635b5e4b2f20bf03178a0cdce53bc9318aa";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      legacyPackages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in (import ./default.nix { inherit pkgs; }) // (import ./lib/flake-projects.nix { inherit inputs pkgs system; }));
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs
        (_: value: nixpkgs.lib.isDerivation value)
        self.legacyPackages.${system});
      ciMetadata = forAllSystems (system: import ./ci-private.nix {
        inherit system;
        inherit (nixpkgs) lib;
        packages = self.packages.${system};
      });
      nixosModules = {
        computer-use = inputs.computer-use.nixosModules.default;
        edunet = inputs.edunet.nixosModules.default;
        gxfp5130-chicago = inputs.gxfp5130Chicago.nixosModules.default;
      };
      overlays = import ./overlays;
      lib.cacheConfig = import ./lib/cache-config.nix;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
