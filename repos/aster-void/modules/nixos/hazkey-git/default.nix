{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.hazkey-git;
  defaultPkg = import ../../../packages/fcitx5-hazkey-git {inherit pkgs;};
in {
  _class = "nixos";
  options.programs.hazkey-git = {
    enable = lib.mkEnableOption "hazkey-git integration";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPkg;
      description = "Hazkey git build providing hazkey-server";
    };
  };
  config = lib.mkIf cfg.enable (let
    pkg = cfg.package;
    bindOpts = ["bind" "ro" "x-systemd.automount" "x-systemd.idle-timeout=1min"];
  in {
    systemd.tmpfiles.rules = [
      "d /usr/share/hazkey 0555 root root -"
      "d /usr/lib/hazkey 0555 root root -"
    ];
    fileSystems."/usr/share/hazkey" = {
      device = "${pkg}/share/hazkey";
      fsType = "none";
      options = bindOpts;
    };
    fileSystems."/usr/lib/hazkey" = {
      device = "${pkg}/lib/hazkey";
      fsType = "none";
      options = bindOpts;
    };
    systemd.user.services.hazkey-server = {
      description = "Hazkey git server";
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStart = "${pkg}/bin/hazkey-server";
        Restart = "on-failure";
      };
    };
  });
}
