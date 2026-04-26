pythonPackages: pythonPackagesSuper:
let
  inherit (pythonPackages) callPackage;
in
{
  # example:
  # rpatool = callPackage ./rpatool { };
}
