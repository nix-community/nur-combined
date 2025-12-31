{
  description = "mrtnvgr's NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [ ./flake ];
    };

  nixConfig = {
    extra-substituters = [ "https://mrtnvgr.cachix.org" ];

    extra-trusted-public-keys = [
      "mrtnvgr.cachix.org-1:zV5Vv57wyo/NNdiLZg0IMjQSLLL0pkEbfeltQ0F4kL8="
    ];
  };
}
