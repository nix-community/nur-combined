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
      _: _: {
        src = pkgs.fetchFromGitHub {
          owner = "svalaskevicius";
          repo = "sway";
          rev = "hiding-lone-titlebar-scenegraph";
          hash = "sha256-cXBEXWUj3n9txzpzDgl6lsNot1ag1sEE07WAwfCLWHc=";
        };
      }
    )).override
      {
        enableXWayland = true;
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
  collada-dom = pkgs.callPackage ./pkgs/collada-dom { };
  qgv = pkgs.libsForQt5.callPackage ./pkgs/qgv { };
  osgqt = pkgs.callPackage ./pkgs/osgqt { };
  gepetto-viewer-base = pkgs.callPackage ./pkgs/gepetto-viewer-base { inherit osgqt qgv; };
  py-gepetto-viewer-base = pkgs.python3Packages.toPythonModule gepetto-viewer-base;
  gepetto-viewer-corba = pkgs.callPackage ./pkgs/gepetto-viewer-corba {
    inherit gepetto-viewer-base;
  };
  py-gepetto-viewer-corba = pkgs.python3Packages.toPythonModule gepetto-viewer-corba;
  gepetto-viewer = pkgs.callPackage ./pkgs/gepetto-viewer {
    inherit gepetto-viewer-base gepetto-viewer-corba;
  };
  ndcurves = pkgs.callPackage ./pkgs/ndcurves { };
  py-ndcurves = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/ndcurves { pythonSupport = true; }
  );
  #multicontact-api = pkgs.callPackage ./pkgs/multicontact-api { };
  #py-multicontact-api = pkgs.python3Packages.toPythonModule (
  #pkgs.callPackage ./pkgs/multicontact-api {
  #pythonSupport = true;
  #}
  #);

  proxsuite = pkgs.callPackage ./pkgs/proxsuite { };
  hpp-centroidal-dynamics = pkgs.callPackage ./pkgs/hpp-centroidal-dynamics { };
  py-hpp-centroidal-dynamics = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/hpp-centroidal-dynamics { pythonSupport = true; }
  );
  hpp-bezier-com-traj = pkgs.callPackage ./pkgs/hpp-bezier-com-traj {
    inherit
      hpp-centroidal-dynamics
      py-hpp-centroidal-dynamics
      ndcurves
      py-ndcurves
      ;
  };
  py-hpp-bezier-com-traj = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/hpp-bezier-com-traj {
      pythonSupport = true;
      inherit
        hpp-centroidal-dynamics
        py-hpp-centroidal-dynamics
        ndcurves
        py-ndcurves
        ;
    }
  );
  hpp-environments = pkgs.callPackage ./pkgs/hpp-environments { };
  hpp-universal-robot = pkgs.callPackage ./pkgs/hpp-universal-robot { };
  hpp-util = pkgs.callPackage ./pkgs/hpp-util { };
  hpp-statistics = pkgs.callPackage ./pkgs/hpp-statistics { inherit hpp-util; };
  hpp-template-corba = pkgs.callPackage ./pkgs/hpp-template-corba { inherit hpp-util; };
  hpp-pinocchio = pkgs.callPackage ./pkgs/hpp-pinocchio { inherit hpp-environments hpp-util; };
  hpp-constraints = pkgs.callPackage ./pkgs/hpp-constraints { inherit hpp-pinocchio hpp-statistics; };
  hpp-baxter = pkgs.callPackage ./pkgs/hpp-baxter { };
  hpp-core = pkgs.callPackage ./pkgs/hpp-core {
    inherit
      hpp-constraints
      hpp-pinocchio
      hpp-statistics
      proxsuite
      ;
  };
  hpp-manipulation = pkgs.callPackage ./pkgs/hpp-manipulation {
    inherit hpp-core hpp-universal-robot;
  };
  hpp-manipulation-urdf = pkgs.callPackage ./pkgs/hpp-manipulation-urdf { inherit hpp-manipulation; };
  hpp-corbaserver = pkgs.callPackage ./pkgs/hpp-corbaserver { inherit hpp-core hpp-template-corba; };
  hpp-romeo = pkgs.callPackage ./pkgs/hpp-romeo { inherit hpp-corbaserver; };
  hpp-manipulation-corba = pkgs.callPackage ./pkgs/hpp-manipulation-corba {
    inherit hpp-corbaserver hpp-manipulation-urdf;
  };
in
{
  inherit
    collada-dom
    gepetto-viewer
    gepetto-viewer-base
    py-gepetto-viewer-base
    gepetto-viewer-corba
    py-gepetto-viewer-corba
    ndcurves
    osgqt
    hpp-centroidal-dynamics
    hpp-bezier-com-traj
    hpp-util
    hpp-environments
    hpp-statistics
    hpp-template-corba
    hpp-pinocchio
    hpp-constraints
    hpp-corbaserver
    hpp-baxter
    hpp-core
    hpp-manipulation
    hpp-manipulation-corba
    hpp-manipulation-urdf
    hpp-romeo
    hpp-universal-robot
    #multicontact-api
    proxsuite
    #py-multicontact-api
    py-ndcurves
    py-hpp-centroidal-dynamics
    py-hpp-bezier-com-traj
    qgv
    ;

  gruppled-white-lite-cursors = pkgs.callPackage ./pkgs/gruppled-lite-cursors {
    theme = "gruppled_white_lite";
  };
  sauce-code-pro = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
  sway-lone-titlebar = pkgs.sway.override { sway-unwrapped = sway-lone-titlebar-unwrapped; };
}
