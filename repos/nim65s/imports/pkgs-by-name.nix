{ inputs, lib, ... }:
{

  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          scope = lib.makeScope pkgs.newScope (_self: {
            inherit inputs;
          });
        in
        lib.filesystem.packagesFromDirectoryRecursive {
          inherit (scope) callPackage;
          directory = ../pkgs/by-name;
        };
    };
}
