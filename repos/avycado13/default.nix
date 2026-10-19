# NUR entry point: nix-env -f . -qa '*', or nix-build -A gitcredits.
{
  pkgs ? import <nixpkgs> { },
}:
{
  overlays = import ./overlays;

  fx = pkgs.callPackage ./pkgs/fx { };
  gitcredits = pkgs.callPackage ./pkgs/gitcredits { };
  brew2nur = pkgs.callPackage ./pkgs/brew2nur { };
  anylinuxfs-gui = pkgs.callPackage ./pkgs/anylinuxfs-gui { };
}
