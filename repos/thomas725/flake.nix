{
  description = "My NUR packages";

  # Use nixpkgs/unstable so that czkawka-git has a new enough rustc by default
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forAllSystems ({ pkgs, system }: import ./default.nix { inherit pkgs; });
    };
}
