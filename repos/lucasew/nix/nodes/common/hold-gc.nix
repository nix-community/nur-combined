{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  options.gc-hold = with lib; {
    paths = mkOption {
      description = "Paths to hold for GC";
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config =
    let

      getPath = drv: drv.outPath;
      flakePaths = lib.attrValues self.inputs;
      allDrvs = config.gc-hold.paths ++ flakePaths;
      paths = map (getPath) allDrvs;
      pathsStr = lib.concatStringsSep "\n" paths;
    in
    {
      environment.etc.nix-gchold.text = pathsStr;
    };
}
