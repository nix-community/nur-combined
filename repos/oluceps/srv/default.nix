{ lib, pkgs, ... }@args:

with lib;
let
  allSrvPath = (lib.subtractLists [ "default.nix" ] (with builtins; attrNames (readDir ./.)));

  allSrvPathNoSuffix = map (removeSuffix ".nix") allSrvPath;

  existSrvOpt = filter (n: builtins.hasAttr n args.config.services) allSrvPathNoSuffix;
in
{
  options.srv = genAttrs allSrvPathNoSuffix (sn: {
    enable = mkEnableOption "${sn} service";
    /*
      Introduce this in per hosts and use with
      srv = { a = { enable = true; override = { opt1 = false; };};}
    */
    override = mkOption {
      type = lib.types.unspecified;
      default = { };
    };
  });

  config.services = genAttrs existSrvOpt (
    n:
    (
      let
        perSrv = args.config.srv.${n};
      in
      (mkIf (perSrv.enable) ((import ./${n}.nix args) // perSrv.override))
    )
  );
}
