{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
  let system = "x86_64-linux";
  in
  {
    packages.${system} = (import ./default.nix {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    });
  };
}
