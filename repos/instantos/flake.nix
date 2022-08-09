{
  description = "instantNIX";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";

    extra-substituters = [
      "https://instantos.cachix.org"
    ];

    extra-trusted-public-keys = [
      "instantos.cachix.org-1:6GezJZuxIK59ydzdyoIw6Yr4H6DaCoLzqhPaDhB8v24="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;
    systems = lib.platforms.linux;
    forAllSystems = lib.genAttrs systems;
    # forAllSystems = f: lib.genAttrs systems (system: f system);
    # lib.filterAttrs (n: v: lib.isDerivation v);
    # lib.filterAttrs (n: lib.isDerivation);
  in {
    packages = forAllSystems (system: {
      default =
        (import ./default.nix {
          pkgs = nixpkgs.legacyPackages.${system} or (import nixpkgs {inherit system;});
        })
        .instantnix;
    });

    nixosModules = (import ./modules).modules;
  };
}
