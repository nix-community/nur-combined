{
  description = "Rajveer Singh's NUR packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forSystems (
        system:
        let
          packages = import ./. { pkgs = nixpkgs.legacyPackages.${system}; };
        in
        packages // { default = packages.nixbox; }
      );
      checks = forSystems (system: import ./. { pkgs = nixpkgs.legacyPackages.${system}; });
      overlays.default = final: _prev: import ./. { pkgs = final; };
    };
}
