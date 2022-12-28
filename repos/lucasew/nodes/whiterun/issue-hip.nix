# Context: https://github.com/NixOS/nixpkgs/issues/207109

{ pkgs, lib, ... }: let
  pytorchNixpkgs = pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "f6d4e98b49a52fe564b832e20527b527fa2c90a6";
    sha256 = "sha256-+dVYl9RTO89gRgzT+qDIRkxmz+NCSq4FsFWLIxYdnto=";
  };
  pytorchPkgs = import pytorchNixpkgs {
    inherit (pkgs) system;
  };
in {
  gc-hold.paths = [
    pytorchPkgs.python3Packages.torchWithRocm
  ];
}
