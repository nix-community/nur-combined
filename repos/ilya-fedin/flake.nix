{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }: let
    lib = import (nixpkgs + "/lib");
    systems = lib.systems.supported.hydra;
    forAllSystems = f: lib.genAttrs systems (system: f system);
  in {
    packages = forAllSystems (system: import ./. {
      pkgs = import nixpkgs { inherit system; };
    });
  };
}
