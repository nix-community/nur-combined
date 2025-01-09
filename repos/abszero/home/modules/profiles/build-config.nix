{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf optionalAttrs;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.buildConfig;
in

{
  imports = [ ./base.nix ];

  options.abszero.profiles.buildConfig.enable =
    mkExternalEnableOption config "profile that disables every package";

  config = mkIf cfg.enable {
    abszero.profiles.base.enable = true;

    programs = builtins.mapAttrs (
      _: v: optionalAttrs (v ? package) { package = pkgs.emptyDirectory; }
    ) config.programs;
  };
}
