# SUPPORT:
# - irc: #gnome-maps on irc.gimp.org
# - Matrix: #gnome-maps:gnome.org  (unclear if bridged to IRC)
#
# INTEGRATIONS:
# - uses https://graphhopper.com for routing
#   - <https://github.com/graphhopper/graphhopper>  (not packaged for Nix)
# - uses https://tile.openstreetmap.org for tiles
# - uses https://overpass-api.de for ... ?
# TIPS:
# - use "Northwest" instead of "NW", and "Street" instead of "St", etc.
#   otherwise, it might not find your destination!
#
# TODO:
# - get gnome-maps to access location services via the xdg-desktop-portal.
#   with it not using the portal, it can't open links via the web browser.
#   additionally, that prevents OpenStreetMap sign-in.
#   even temporarily enabling the portal for OSM doesn't work *after* the portal has been disabled -- because then gnome-maps can't access its passwords (?)
#   possibly this can be fixed by specifing OSM auth statically via gsettings
{ pkgs, ... }:
{
  sane.programs.gnome-maps = {
    packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.gnome-maps.overrideAttrs (base: {
      # TODO: set up portal-based location services, but until that works, explicitly disable portals here.
      preFixup = (base.preFixup or "") + ''
        gappsWrapperArgs+=(
          --unset GIO_USE_PORTALS
        )
      '';
    }));
    suggestedPrograms = [
      "geoclue2"
    ];

    sandbox.wrapperType = "inplace";  #< /share directory contains Gir info which references libgnome-maps.so by path
    sandbox.whitelistDri = true;  # for perf
    sandbox.whitelistDbus = [
      "system"  # system is required for non-portal location services
      "user"  #< not sure if "user" is necessary?
    ];
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";

    sandbox.mesaCacheDir = ".cache/gnome-maps/mesa";
    persist.byStore.plaintext = [ ".cache/shumate" ];
    # ~/.local/share/gnome-maps/places.json (previously: ../maps-places.json); to persist starred locations, recent locations+routes
    # TODO: building in "developer mode" causes gnome-maps to pretty-print the .json instead of minifying it
    persist.byStore.private = [ ".local/share/gnome-maps" ];

    mime.associations."x-scheme-handler/maps" = "org.gnome.Maps.desktop";  # e.g. `maps:q=1600%20Pennsylvania%20Ave`
  };
}
