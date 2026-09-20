{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.ublksrv;

  controlRule =
    if cfg.unprivileged.group == null then
      ''KERNEL=="ublk-control", MODE="0666", OPTIONS+="static_node=ublk-control"''
    else
      ''KERNEL=="ublk-control", GROUP="${cfg.unprivileged.group}", MODE="0660", OPTIONS+="static_node=ublk-control"'';

  chown = "${cfg.package}/libexec/ublk_chown.sh";

  # ublksrv daemons hard-code /run/ublksrvd for pid files.
  # Upstream creates it 0777 on first (root) use; pre-create it so unprivileged
  # daemons can write there before root ever runs ublk, and add the sticky bit
  # so users cannot remove each other's pid files.
  runDir =
    if cfg.unprivileged.group == null then
      "d /run/ublksrvd 1777 root root -"
    else
      "d /run/ublksrvd 1770 root ${cfg.unprivileged.group} -";
in
{
  options.programs.ublksrv = {
    enable = lib.mkEnableOption "ublksrv, the userspace ublk block device framework";

    package = lib.mkPackageOption pkgs "ublksrv" { };

    unprivileged = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to allow unprivileged users to create and manage ublk
          devices. Installs udev rules that open up `/dev/ublk-control`
          and hand ownership of newly created `ublkb*`/`ublkc*` device
          nodes to the user who created them (`ublk add --unprivileged`).
        '';
      };

      group = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "ublk";
        description = ''
          Restrict access to `/dev/ublk-control` to members of this group.
          When `null`, every user may control ublk devices.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    boot.kernelModules = [ "ublk_drv" ];

    services.udev.extraRules = lib.mkIf cfg.unprivileged.enable ''
      ${controlRule}
      ACTION=="add", KERNEL=="ublk[bc]*", RUN+="${chown} %k 'add' '%M' '%m'"
      ACTION=="remove", KERNEL=="ublk[bc]*", RUN+="${chown} %k 'remove' '%M' '%m'"
    '';

    systemd.tmpfiles.rules = lib.mkIf cfg.unprivileged.enable [ runDir ];

    users.groups = lib.mkIf (cfg.unprivileged.enable && cfg.unprivileged.group != null) {
      ${cfg.unprivileged.group} = { };
    };
  };
}
