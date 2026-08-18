{
  description = "arch-fan NUR packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      packages = import ./. {
        inherit pkgs;
      };
    in
    {
      packages.${system} = packages;
    };
}
