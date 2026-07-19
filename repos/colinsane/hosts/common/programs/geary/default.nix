# geary is a gtk3 email client.
# outstanding issues:
# - it uses webkitgtk_4_1, which is expensive to build.
#   could be upgraded to webkitgtk latest if upgraded to gtk4
#   <https://gitlab.gnome.org/GNOME/geary/-/issues/1212>
{ config, lib, ... }:
let
  cfg = config.sane.programs."geary";
in
{
  sane.programs."geary" = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    # packageUnwrapped = pkgs.geary-gtk4;  #< XXX(2026-04-01): not ready yet; quietly stops receiving mail

    suggestedPrograms = [
      "gnome-keyring"
    ];

    sandbox.wrapperType = "inplace";  #< XXX(2024-08-20): if executed from a directory different than the configured prefix, it fails to locate its sql migration files
    sandbox.net = "clearnet";
    # sandbox.whitelistDbus.user = true;  #< N.B.: geary does its own sandboxing; uncomment if not using nesting-capable xdg-dbus-proxy.
    sandbox.whitelistDbus.user.call."org.freedesktop.secrets" = "*";  #< TODO: restrict to a subset of secrets
    sandbox.whitelistDbus.user.call."org.gnome.evolution.dataserver.*" = "*";
    sandbox.whitelistDbus.user.own = [ "org.gnome.Geary" ];
    sandbox.whitelistPortal = [ "FileChooser" "OpenURI" "Print" ];  #< unsure if all these are actually used
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
      # geary sandboxes *itself* with bwrap, and dbus-proxy which, confusingly, causes it to *require* these paths.
      # TODO: these could maybe be mounted empty. or maybe there's an env-var to disable geary's dbus-proxy.
      "/sys/block"
      "/sys/bus"
      "/sys/class"
      "/sys/dev"
      "/sys/devices"
      "/sys/fs"
    ];
    # if sandbox.method == "landlock", then these dirs must exist in the sandbox, even if empty.
    # fs.".config/geary".dir = {};
    # fs.".local/share/folks".dir = {};

    buildCost = 3;  # uses webkitgtk 4.1
    sandbox.mesaCacheDir = ".cache/geary/mesa";
    persist.byStore.private = [
      # attachments, and email -- contained in a sqlite db
      ".local/share/geary"
      # also `.cache/geary/web-resources`, which tends to stay << 1 MiB
    ];
    fs.".config/geary/account_01/geary.ini".symlink.target = ./account_01_geary.ini;
    secrets.".config/geary/account_02/geary.ini" = ../../../../secrets/common/geary_account_02.ini.bin;

    services.geary = {
      description = "geary email client";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      command = "geary";
    };
  };

}
