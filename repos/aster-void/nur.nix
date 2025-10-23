{pkgs ? import <nixpkgs> {}}: let
  mkNixosModule = path: {
    _class = "nixos";
    imports = [path];
  };
in {
  cargo-compete = pkgs.callPackage ./packages/cargo-compete {inherit pkgs;};
  fcitx5-hazkey = pkgs.callPackage ./packages/fcitx5-hazkey {inherit pkgs;};
  chrome-devtools-mcp = pkgs.callPackage ./packages/chrome-devtools-mcp {inherit pkgs;};
  bibata-cursors-translucent = import ./packages/bibata-cursors-translucent {inherit pkgs;};
  modules = {
    chrome-devtools-mcp = mkNixosModule ./modules/nixos/chrome-devtools-mcp;
    hazkey = mkNixosModule ./modules/nixos/hazkey;
  };
}
