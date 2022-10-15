{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.flake-compat = {
    url = github:edolstra/flake-compat;
    flake = false;
  };

  outputs = { nixpkgs, ... }: let
    lib = import (nixpkgs + "/lib");
    forAllSystems = f: lib.genAttrs lib.systems.flakeExposed (system: f system);
  in {
    packages = forAllSystems (system: import ./. {
      pkgs = import nixpkgs { inherit system; };
    });
  };
}
