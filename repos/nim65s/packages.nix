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
      _final: prev: {
        src = pkgs.fetchFromGitHub {
          owner = "svalaskevicius";
          repo = "sway";
          #rev = "hiding-lone-titlebar-scenegraph";
          rev = "c618290172b745e0d86daa92de479832171c1eb5";
          hash = "sha256-U852/FLD6Ox41QfLXHbB3LagIg+I7th/9P1Opr8Tmpc=";
        };
        mesonFlags = builtins.filter (e: e != "-Dxwayland=enabled") prev.mesonFlags;
      }
    )).override
      {
        enableXWayland = true;
        wlroots = pkgs.wlroots.overrideAttrs {
          version = "0.19.0-dev";
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "wlroots";
            repo = "wlroots";
            rev = "015bb8512ee314e1deb858cf7350b0220fc58702";
            hash = "sha256-Awi0iSdtaqAxoXb8EMlZC6gvyW5QtsPrBAl41c2Y9rg=";
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
  py-hpp-corbaserver = pkgs.python3Packages.toPythonModule hpp-corbaserver;
  hpp-romeo = pkgs.callPackage ./pkgs/hpp-romeo { inherit hpp-corbaserver; };
  hpp-manipulation-corba = pkgs.callPackage ./pkgs/hpp-manipulation-corba {
    inherit hpp-corbaserver hpp-manipulation-urdf;
  };
  py-hpp-manipulation-corba = pkgs.python3Packages.toPythonModule hpp-manipulation-corba;
  hpp-tutorial = pkgs.callPackage ./pkgs/hpp-tutorial { inherit hpp-manipulation-corba; };
  py-hpp-tutorial = pkgs.python3Packages.toPythonModule hpp-tutorial;
  hpp-gepetto-viewer = pkgs.callPackage ./pkgs/hpp-gepetto-viewer {
    inherit gepetto-viewer-corba hpp-corbaserver;
  };
  py-hpp-gepetto-viewer = pkgs.python3Packages.toPythonModule hpp-gepetto-viewer;
  hpp-plot = pkgs.callPackage ./pkgs/hpp-plot {
    inherit gepetto-viewer-corba hpp-manipulation-corba;
  };
  hpp-gui = pkgs.callPackage ./pkgs/hpp-gui { inherit gepetto-viewer-corba hpp-manipulation-corba; };
  hpp-practicals = pkgs.callPackage ./pkgs/hpp-practicals {
    inherit hpp-gepetto-viewer hpp-gui hpp-plot;
  };
  py-hpp-practicals = pkgs.python3Packages.toPythonModule hpp-practicals;
  gepetto-viewer = pkgs.callPackage ./pkgs/gepetto-viewer {
    inherit
      gepetto-viewer-base
      gepetto-viewer-corba
      hpp-gepetto-viewer
      hpp-gui
      hpp-plot
      ;
  };
  liblzf = pkgs.callPackage ./pkgs/liblzf { };
  tinygltf = pkgs.callPackage ./pkgs/tinygltf { };
  filament = pkgs.callPackage ./pkgs/filament { };
  open3d = pkgs.callPackage ./pkgs/open3d { inherit liblzf tinygltf filament; };
  py-open3d = pkgs.python3Packages.toPythonModule open3d;
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
    hpp-gui
    hpp-util
    hpp-environments
    hpp-statistics
    hpp-template-corba
    hpp-pinocchio
    hpp-constraints
    hpp-corbaserver
    hpp-baxter
    hpp-core
    hpp-gepetto-viewer
    hpp-manipulation
    hpp-manipulation-corba
    hpp-manipulation-urdf
    hpp-plot
    hpp-practicals
    hpp-romeo
    hpp-tutorial
    hpp-universal-robot
    liblzf
    #multicontact-api
    open3d
    proxsuite
    #py-multicontact-api
    py-hpp-corbaserver
    py-hpp-gepetto-viewer
    py-ndcurves
    py-hpp-centroidal-dynamics
    py-hpp-bezier-com-traj
    py-hpp-manipulation-corba
    py-hpp-practicals
    py-hpp-tutorial
    py-open3d
    qgv
    tinygltf
    filament
    ;

  gruppled-white-lite-cursors = pkgs.callPackage ./pkgs/gruppled-lite-cursors {
    theme = "gruppled_white_lite";
  };
  sauce-code-pro = pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; };
  sway-lone-titlebar = pkgs.sway.override { sway-unwrapped = sway-lone-titlebar-unwrapped; };
}
