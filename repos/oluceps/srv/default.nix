{ lib, pkgs, ... }@args:

let
  inherit (lib)
    types
    subtractLists
    removeSuffix
    filter
    genAttrs
    mkEnableOption
    mkOption
    mkIf
    ;

  inherit (types) lazyAttrsOf unspecified;

  allSrvPath = (subtractLists [ "default.nix" ] (with builtins; attrNames (readDir ./.)));

  allSrvName = map (removeSuffix ".nix") allSrvPath;

  existSrvName = filter (n: args.config.services ? ${n}) allSrvName;
in
{
  options.srv = genAttrs allSrvName (sn: {
    enable = mkEnableOption "${sn} service";
    override = mkOption {
      type = lazyAttrsOf unspecified;
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
