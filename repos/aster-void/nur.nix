{pkgs ? import <nixpkgs> {}}: let
  mkNixosModule = path: args: (import path args) // {_class = "nixos";};
in {
  cargo-compete = pkgs.callPackage ./packages/cargo-compete {};
  fcitx5-hazkey = pkgs.callPackage ./packages/fcitx5-hazkey {};
  modules = {
    chrome-devtools-mcp = mkNixosModule ./modules/nixos/chrome-devtools-mcp;
    hazkey = mkNixosModule ./modules/nixos/hazkey;
  };
}
