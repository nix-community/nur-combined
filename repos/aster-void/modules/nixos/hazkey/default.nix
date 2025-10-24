{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.hazkey;
  fcitx5-hazkey = import ../../../packages/fcitx5-hazkey {inherit pkgs;};
in {
  _class = "nixos";

  options.programs.hazkey = {
    enable = lib.mkEnableOption "hazkey";
    package = lib.mkOption {
      type = lib.types.package;
      default = fcitx5-hazkey;
      description = "The package to use for fcitx5-hazkey";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "L+ /usr/share/hazkey - - - - ${cfg.package}/share/hazkey"
    ];
  };
}
