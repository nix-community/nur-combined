{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  etime = pkgs.callPackage ./pkgs/etime { };
  gon =
    if pkgs.system == "x86_64-darwin" || pkgs.system == "aarch64-darwin" then
      pkgs.callPackage ./pkgs/gon { }
    else
      null;
  jtt-nvim = pkgs.callPackage ./pkgs/jtt-nvim { };
  jurigged = pkgs.callPackage ./pkgs/jurigged { };
  llrt = pkgs.callPackage ./pkgs/llrt { };
  newsflash-nvim = pkgs.callPackage ./pkgs/newsflash-nvim { };
  proximity-nvim = pkgs.callPackage ./pkgs/proximity-nvim { };
  quill = pkgs.callPackage ./pkgs/quill { };
  zsh-wd = pkgs.callPackage ./pkgs/zsh-wd { };
}
