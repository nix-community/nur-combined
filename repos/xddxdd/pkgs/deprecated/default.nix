{
  loadPackages,
  ...
}:
let
  packages = loadPackages ./. { };
in
packages
