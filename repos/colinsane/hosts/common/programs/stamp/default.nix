# DEBUGGING/COMMON FIXES:
#
### PROBLEM: stamp doesn't render a GUI, nor any notifications.
# SOLUTION: ensure ~/.local/share/keyringsd/Default_keyring.keyring contains one key for each account.
#
# these keys look like:
# ```
# [99]
# item-type=0
# display-name=Evolution Data Source "${email_address}" (Mail Account - imapx)  of stamp-${account_id}-collection
# secret=...
# mtime=...
# ctime=...
#
# [99:attribute0]
# name=e-source-uid
# type=string
# value=stamp-${account_id}-account
#
# [99:attribute1]
# name=eds-origin
# type=string
# value=evolution-data-server
#
# [99:attribute2]
# name=xdg:schema
# type=string
# value=org.gnome.Evolution.Data.Source
# ```
#
# if a key is missing:
# - `systemctl stop gnome-keyring stamp`
# - copy the key(s) from another machine.
#   just edit the keyring file with vim, and choose any secret id (`[99]`) not in use.
# - `systemctl start gnome-keyring`
# - `systemctl start stamp`
{ config, lib, ... }:
let
  cfg = config.sane.programs."stamp";
in
{
  sane.programs.stamp = {
    configOption =
      with lib;
      mkOption {
        default = { };
        type = types.submodule {
          options.autostart = mkOption {
            type = types.bool;
            default = true;
          };
        };
      };

    # packageUnwrapped = pkgs.stamp.overrideAttrs (prevAttrs:
    #   lib.warnIf (lib.versionOlder "0-unstable-2026-11-12" prevAttrs.version) "new stamp release: drop override?"
    # {
    #   # XXX: update to acquire the patch shown further down. It was merged, but does not cleanly apply to old src.
    #   version = "0-unstable-2026-11-12";
    #   src = prevAttrs.src.overrideAttrs {
    #     rev = "b60f940f73b3496c8ad3c5d84162e62da800e22e";
    #     hash = "sha256-MgiiB2vmoPybVBU3uP47TYTHOcs3NevkpgKxwFEUxpA=";
    #   };
    #   # patches = (prevAttrs.patches or []) ++ [
    #   #   (pkgs.fetchurl {
    #   #     # merged 2026-10-26; remove on next update.
    #   #     # this fixes an issue where stamp executes but never renders its GUI nor notifies of mail.
    #   #     # that issue seems to only appear when the account is logged out, e.g. ~/.local/share/keyrings has no creds.
    #   #     # (the alternative may be to manually populate the keyring, not sure).
    #   #     name = "StampAccount-Make-mail-setup-async";
    #   #     url = "https://gitlab.gnome.org/jbrummer/stamp/-/merge_requests/313.diff";
    #   #     hash = "sha256-3l1CKlpLe9ePBJhshzUMEdx5FNi+xZ5XmvIki4afU+g=";
    #   #   })
    #   # ];
    # });

    sandbox.net = "clearnet";
    sandbox.whitelistDbus.user.call."org.freedesktop.secrets" = "*"; # TODO: restrict to a subset of secrets
    sandbox.whitelistDbus.user.call."org.gnome.evolution.dataserver.*" = "*";
    sandbox.whitelistDbus.user.own = [ "org.tabos.stamp" ];
    sandbox.whitelistPortal = [
      "FileChooser" # likely unused
      "OpenURI"
    ];
    sandbox.whitelistSendNotifications = true;
    sandbox.whitelistWayland = true;
    sandbox.extraEnv.GIO_USE_NETWORK_MONITOR = "netlink"; # required if portal NetworkMonitor isn't exposed (probably?)
    sandbox.extraEnv.GIO_USE_PROXY_RESOLVER = "dummy"; # required if portal NetworkMonitor isn't exposed

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

    secrets.".config/evolution/sources/stamp-02-account.source" =
      ../../../../secrets/common/stamp/stamp-02-account.source.bin;
    secrets.".config/evolution/sources/stamp-02-collection.source" =
      ../../../../secrets/common/stamp/stamp-02-collection.source.bin;
    secrets.".config/evolution/sources/stamp-02-identity.source" =
      ../../../../secrets/common/stamp/stamp-02-identity.source.bin;
    secrets.".config/evolution/sources/stamp-02-transport.source" =
      ../../../../secrets/common/stamp/stamp-02-transport.source.bin;

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
