new: old:
let
  newPackagePaths = import /${old.vacuRoot}/pythonPackages { inherit (old) lib vaculib; };
in
{
  pythonPackagesExtensions = old.pythonPackagesExtensions ++ [
    (newpy: _oldpy: builtins.mapAttrs (_: path: newpy.callPackage path { }) newPackagePaths)
  ];
}
