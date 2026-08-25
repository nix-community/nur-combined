{
  description = "My personal NUR repository";

  nixConfig = {
    extra-substituters = [
      "https://pedorich-n-nur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pedorich-n-nur.cachix.org-1:EisUgiRsKFmZ3LJN7r29oDae+Wxq9FQpkcydRx19N7Q="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ndg = {
      url = "github:feel-co/ndg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = lib.systems.flakeExposed;

        imports = lib.filesystem.listFilesRecursive ./flake-parts;

        debug = true;
      }
    );
}
