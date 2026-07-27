{ callPackage, ... }:

{
  types = callPackage ./types.nix { };

  prefixPythonSubmodules = callPackage ./prefix-python-submodules.nix { };
}
