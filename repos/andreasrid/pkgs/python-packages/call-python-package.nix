{
  pkgs,
  python ? pkgs.python3,
  self ? { },
}:
let
  pythonEnv = python.pkgs;
in
pkgs.lib.callPackageWith (
  pkgs
  // python.pkgs
  // {
    python3 = python;
    python3Packages = python.pkgs;
  }
  // import ./. { inherit python pkgs; }
  // self
)
