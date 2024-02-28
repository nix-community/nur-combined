{ pkgs, ... }:
{
  sane.programs."gnome.gnome-maps" = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.gnome.gnome-maps;
    sandbox.method = "bwrap";
    sandbox.whitelistDri = true;  # for perf
    sandbox.whitelistDbus = [
      "system"  # system is required for non-portal location services
      "user"  #< not sure if "user" is necessary?
    ];
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";
    sandbox.usePortal = false;  # TODO: set up portal-based location services

    persist.byStore.plaintext = [ ".cache/shumate" ];
    persist.byStore.private = [
      ({ path = ".local/share/maps-places.json"; type = "file"; })
    ];
  };
}
