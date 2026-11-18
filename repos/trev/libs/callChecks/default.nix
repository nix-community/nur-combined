{
  lib,
  pkgs,
}:

# callPackage for a file of checks: a directory resolves to its checks.nix,
# a function file is called with what it asks for from pkgs plus `args`.
path: args:
let
  file = if lib.pathIsDirectory path then path + "/checks.nix" else path;

  imported = import file;

  autoArgs = pkgs // {
    inherit pkgs;
  };

  checks =
    if lib.isFunction imported then
      imported (builtins.intersectAttrs (lib.functionArgs imported) autoArgs // args)
    else
      imported;
in
# mkChecks flattens groups into its own checks, prefixing each name with the group's
{
  _type = "checks";
  inherit checks;
}
