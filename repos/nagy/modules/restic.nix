{
  config,
  lib,
  pkgs,
  nur,
  ...
}:

let
  cfg = config.nagy.restic;
  packages = lib.mapAttrsToList (
    name: value: nur.repos.nagy.lib.mkResticWrapper ({ inherit name; } // value)
  ) cfg.attrs;
in
{
  options.nagy.restic = {
    attrs = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "restic attrs";
    };
  };

  config = {
    environment.systemPackages = [
      pkgs.restic
      # pkgs.rustic
    ] ++ packages;
    nagy.shortcommands.commands = lib.mergeAttrsList (map (x: x.shortcommands) packages);
  };
}
