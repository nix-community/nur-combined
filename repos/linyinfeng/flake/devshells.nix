{ ... }:

{
  perSystem = { self', lib, ... }:
    let
      commandFor = p: args: lib.optional (self'.packages ? ${p}) ({ package = self'.packages.${p}; } // args);
    in
    {
      devshells.default = {
        devshell.name = "linyinfeng/nur-packages";
        commands = commandFor "devPackages/update" { };
      };
    };
}
