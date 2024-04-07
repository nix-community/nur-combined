# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  sway-lone-titlebar-unwrapped =
    (pkgs.sway-unwrapped.overrideAttrs (
      finalAttrs: previousAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "svalaskevicius";
          repo = "sway";
          rev = "hiding-lone-titlebar-scenegraph";
          hash = "sha256-cXBEXWUj3n9txzpzDgl6lsNot1ag1sEE07WAwfCLWHc=";
        };
      }
    )).override
      {
        wlroots = pkgs.wlroots.overrideAttrs {
          version = "0.18.0-dev";
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "wlroots";
            repo = "wlroots";
            rev = "873e8e455892fbd6e85a8accd7e689e8e1a9c776";
            hash = "sha256-5zX0ILonBFwAmx7NZYX9TgixDLt3wBVfgx6M24zcxMY=";
          };
          patches = [ ];
        };
      };
  osgqt = pkgs.libsForQt5.callPackage ./pkgs/osgqt { };
  qgv = pkgs.libsForQt5.callPackage ./pkgs/qgv { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  inherit osgqt qgv;

  gepetto-viewer = pkgs.libsForQt5.callPackage ./pkgs/gepetto-viewer { inherit osgqt qgv; };
  gruppled-black-cursors = pkgs.callPackage ./pkgs/gruppled-cursors { theme = "gruppled_black"; };
  gruppled-black-lite-cursors = pkgs.callPackage ./pkgs/gruppled-lite-cursors {
    theme = "gruppled_black_lite";
  };
  gruppled-white-cursors = pkgs.callPackage ./pkgs/gruppled-cursors { theme = "gruppled_white"; };
  gruppled-white-lite-cursors = pkgs.callPackage ./pkgs/gruppled-lite-cursors {
    theme = "gruppled_white_lite";
  };
  ndcurves = pkgs.callPackage ./pkgs/ndcurves { };
  py-ndcurves = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/ndcurves { pythonSupport = true; }
  );
  qpoases = pkgs.callPackage ./pkgs/qpoases { };
  sauce-code-pro = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
  sway-lone-titlebar = pkgs.sway.override { sway-unwrapped = sway-lone-titlebar-unwrapped; };
}
