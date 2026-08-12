{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  options.gc-hold = with lib; {
    enable = mkEnableOption "prefetch a set of paths";
    paths = mkOption {
      description = "Paths to hold for GC";
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config = lib.mkIf config.gc-hold.enable {
    environment.etc.nix-gchold.text =
      let

        getPath = drv: drv.outPath;
        flakePaths = lib.attrValues self.inputs;
        allDrvs = config.gc-hold.paths ++ flakePaths;
        paths = map (getPath) allDrvs;
        pathsStr = lib.concatStringsSep "\n" paths;

      in
      pathsStr;
  };
}
