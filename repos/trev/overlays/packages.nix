{ }:
_: prev:
let
  packages = import ../packages {
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
  };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pythonPackages: _: import ../packages/python.nix { inherit pythonPackages; })
  ];
in
prev
// packages
// {
  inherit pythonPackagesExtensions;
}
