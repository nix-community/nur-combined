{
  options,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf optionalAttrs;
  cfg = config.abszero.profiles.buildConfig;
in

{
  imports = [ ./base.nix ];

  options.abszero.profiles.buildConfig.enable = mkEnableOption "profile that disables every package";

  config = mkIf cfg.enable {
    abszero.profiles.base.enable = true;

    programs = builtins.mapAttrs (
      _: v:
      optionalAttrs (v ? package && !(v ? package.readOnly && v.package.readOnly)) {
        package = pkgs.emptyDirectory;
      }
    ) options.programs;
  };
}
