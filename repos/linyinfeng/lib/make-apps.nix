{ lib }:

packages: appNames:

let
  mkAppsSingle =
    p: drv:
    lib.mapAttrsToList (
      appName: exec:
      lib.nameValuePair appName {
        type = "app";
        program = "${drv}/bin/${exec}";
      }
    ) (appNames p);
in
lib.listToAttrs (lib.flatten (lib.mapAttrsToList mkAppsSingle packages))
