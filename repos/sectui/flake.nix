{
  description = "NUR repository of the sectui security tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: import ./default.nix {pkgs = nixpkgs.legacyPackages.${system};});

    overlays.default = final: _prev: import ./default.nix {pkgs = final;};
  };
}
