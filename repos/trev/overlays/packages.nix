{ }:
_: prev:
let
  packages = import ../packages {
    system = prev.stdenv.buildPlatform.system;
    pkgs = prev;
    includeFlakePackages = true;
  };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pythonPackages: _: import ../packages/python.nix { inherit pythonPackages; })
  ];

  beamPackages =
    prev.beamPackages // import ../packages/beam.nix { beamPackages = prev.beamPackages; };
in
prev
// packages
// {
  inherit pythonPackagesExtensions beamPackages;
}
