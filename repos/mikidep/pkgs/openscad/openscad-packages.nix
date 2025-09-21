{
  lib,
  linkFarm,
  fetchFromGitHub,
}: let
  mkLib = name: src: linkFarm name {${name} = src;};
in
  lib.mapAttrs (name: src: mkLib name src) {
    BOSL2 = fetchFromGitHub {
      owner = "BelfrySCAD";
      repo = "BOSL2";
      rev = "1ef1cc1";
      hash = "sha256-aau/LJ+2Go0rNMF/R+DFpQWt406nJQpBsqUzrnUd958=";
    };
    lasercut-box-openscad = fetchFromGitHub {
      owner = "larsch";
      repo = "lasercut-box-openscad";
      rev = "0496a3a";
      hash = "sha256-L7cOuIUElCttGGPYZadp/1A986HlzMoBHKj1xk6B+vI=";
    };
    mikidep-scad = fetchFromGitHub {
      owner = "mikidep";
      repo = "mikidep-scad";
      rev = "ae650c8";
      hash = "sha256-DYqpqExrRtV41Q3xQ/tAtv1JdUTapamhLsTiaU5RqYw=";
    };
    fastvoronoi = ./fastvoronoi;
    nopscadlib = fetchFromGitHub {
      owner = "nophead";
      repo = "NopSCADlib";
      rev = "cae9cdd";
      hash = "sha256-7dCbQV6rwgH1n4KBcB04FEYSIW5rdLLPNKF7wKgZ8zg=";
    };
  }
