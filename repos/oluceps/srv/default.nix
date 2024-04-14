{ lib, pkgs, ... }@args:

with lib;
let
  allSrvPath = (lib.subtractLists [ "default.nix" ] (with builtins; attrNames (readDir ./.)));

  allSrvName = map (removeSuffix ".nix") allSrvPath;

  existSrvName = filter (n: args.config.services ? ${n}) allSrvName;
in
{
  options.srv = genAttrs allSrvName (sn: {
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

  config.services = genAttrs existSrvName (
    n:
    (
      let
        perSrv = args.config.srv.${n};
      in
      (mkIf (perSrv.enable) ((removeAttrs (import ./${n}.nix args) [ "attach" ]) // perSrv.override))
    )
  );
}
