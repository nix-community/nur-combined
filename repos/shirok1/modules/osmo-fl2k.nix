{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.osmo-fl2k;
in
{
  options.services.osmo-fl2k = {
    enable = lib.mkEnableOption "Enable osmo-fl2k";

    package = lib.mkOption {
      type = lib.types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.osmo-fl2k);
      defaultText = lib.literalMD "`packages.osmo-fl2k` from the shirok1/flakes flake";
      description = "The osmo-fl2k package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.udev.packages = [ cfg.package ];
  };
}
