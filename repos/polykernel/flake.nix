{
  description = "An experimental NUR repository";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils?ref=master";
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
    ];

    pureOutputs = {
      modules = import ./modules;
    };

    systemDependentOutputs = system: {
      packages =
        flake-utils.lib.filterPackages system
        (
          flake-utils.lib.flattenTree
          (import ./pkgs {
            pkgs = import nixpkgs {inherit system;};
          })
        );
    };
  in
    pureOutputs
    // flake-utils.lib.eachSystem supportedSystems systemDependentOutputs;
}
