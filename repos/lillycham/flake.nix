{
  description = "Lilly's NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      legacyPackages = forAllSystems (pkgs: import ./default.nix { inherit pkgs; });
      packages = forAllSystems (pkgs:
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v && nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform v)
          self.legacyPackages.${pkgs.stdenv.hostPlatform.system});
    };
}
