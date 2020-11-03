{ mergedPkgs, pythonPackages }:

mergedPkgs.lib.fix (self:
let
  mergedPythonPackages = pythonPackages // self;
  callPackage = mergedPkgs.newScope mergedPythonPackages;
in
with mergedPythonPackages; {
  inherit callPackage;

  debugpy = callPackage ./debugpy { };

  pygls = callPackage ./pygls { };

  pytest-datadir = callPackage ./pytest-datadir { };

  vdf = callPackage ./vdf { };
})
