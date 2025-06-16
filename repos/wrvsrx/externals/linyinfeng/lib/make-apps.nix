{ lib }:

packages: appNames:

let
  mkAppsSingle =
    p: drv:
    lib.mapAttrsToList (
      appName: exec:
      lib.nameValuePair appName (
        {
          type = "app";
          program = "${drv}/bin/${exec}";
        }
        // lib.optionalAttrs (drv ? meta.description) {
          meta.description = drv.meta.description;
        }
      )
    ) (appNames p);
in
lib.listToAttrs (lib.flatten (lib.mapAttrsToList mkAppsSingle packages))
