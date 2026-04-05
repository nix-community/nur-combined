pythonPackages: pythonPackagesSuper:
let
  inherit (pythonPackages) callPackage;
in
{
  rpatool = callPackage ./rpatool { };
}
