{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }: {
    packages.x86_64-linux = (import ./default.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; }).pkgs;
  };
}