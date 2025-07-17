{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: let
    inherit (nixpkgs.lib) genAttrs;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = genAttrs systems;
  in {
    packages = forAllSystems (system:
      let
        localpkgs = self.packagesFunc nixpkgs.legacyPackages.${system};
      in localpkgs // { default = localpkgs.vieb; }
    );
    packagesFunc = pkgs: import ./default.nix { inherit pkgs; };
  };
}
