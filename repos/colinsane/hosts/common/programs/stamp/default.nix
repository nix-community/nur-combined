{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs."stamp";
in
{
  sane.programs.stamp = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    sandbox.net = "clearnet";
    sandbox.whitelistDbus.user.call."org.freedesktop.secrets" = "*";  #< TODO: restrict to a subset of secrets
    sandbox.whitelistDbus.user.call."org.gnome.evolution.dataserver.*" = "*";
    sandbox.whitelistDbus.user.own = [ "org.tabos.stamp" ];
    sandbox.whitelistPortal = [
      "FileChooser"  #< likely unused
      "OpenURI"
    ];
    sandbox.whitelistSendNotifications = true;
    sandbox.whitelistWayland = true;
    sandbox.extraEnv.GIO_USE_NETWORK_MONITOR = "netlink";  #< required if portal NetworkMonitor isn't exposed (probably?)
    sandbox.extraEnv.GIO_USE_PROXY_RESOLVER = "dummy";  #< required if portal NetworkMonitor isn't exposed

    sandbox.extraHomePaths = [
      # it shouldn't need these, but portal integration seems incomplete?
      "tmp"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
    ];
    sandbox.extraPaths = [
      # stamp sandboxes *itself* with bwrap, and dbus-proxy which, confusingly, causes it to *require* these paths.
      # TODO: these could maybe be mounted empty.
      "/sys/block"
      "/sys/bus"
      "/sys/class"
      "/sys/dev"
      "/sys/devices"
    ];

    buildCost = 2;
    sandbox.mesaCacheDir = ".cache/stamp/mesa";

    suggestedPrograms = [
      "evolution-data-server"
      "gnome-keyring"
    ];

    persist.byStore.private = [
      ".cache/stamp"
    ];

    fs.".config/evolution/sources/stamp-colin_uninsane_org-account.source".symlink.target =
      ./stamp-colin_uninsane_org-account.source;
    fs.".config/evolution/sources/stamp-colin_uninsane_org-collection.source".symlink.target =
      ./stamp-colin_uninsane_org-collection.source;
    fs.".config/evolution/sources/stamp-colin_uninsane_org-identity.source".symlink.target =
      ./stamp-colin_uninsane_org-identity.source;
    fs.".config/evolution/sources/stamp-colin_uninsane_org-transport.source".symlink.target =
      ./stamp-colin_uninsane_org-transport.source;

    secrets.".config/evolution/sources/stamp-02-account.source" = ../../../../secrets/common/stamp/stamp-02-account.source.bin;
    secrets.".config/evolution/sources/stamp-02-collection.source" = ../../../../secrets/common/stamp/stamp-02-collection.source.bin;
    secrets.".config/evolution/sources/stamp-02-identity.source" = ../../../../secrets/common/stamp/stamp-02-identity.source.bin;
    secrets.".config/evolution/sources/stamp-02-transport.source" = ../../../../secrets/common/stamp/stamp-02-transport.source.bin;

    services.stamp = {
      description = "stamp email client";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      command = "stamp";
    };
  };

  sane.programs.evolution-data-server.sandbox.extraHomePaths = lib.mkIf cfg.enabled [
    ".config/evolution/sources/stamp-02-account.source"
    ".config/evolution/sources/stamp-02-collection.source"
    ".config/evolution/sources/stamp-02-identity.source"
    ".config/evolution/sources/stamp-02-transport.source"
  ];
}
