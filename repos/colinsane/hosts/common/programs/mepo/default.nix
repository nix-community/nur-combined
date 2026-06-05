# docs: <https://git.sr.ht/~mil/mepo>
# irc #mepo:irc.oftc.net
#
{ pkgs, ... }:
{
  sane.programs.mepo = {
    packageUnwrapped = pkgs.mepo.overrideAttrs (base: {
      # TODO: set up portal-based location services, but until that works, explicitly disable portals here.
      preFixup = (base.preFixup or "") + ''
        gappsWrapperArgs+=(
          --unset GIO_USE_PORTALS
        )
      '';
    });
    sandbox.net = "all";  # for tiles *and* for localhost comm to gpsd
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus.system = true;  # system is required for non-portal location services
    sandbox.whitelistDbus.user = true;  #< TODO: not sure if "user" is necessary?
    sandbox.mesaCacheDir = ".cache/mepo/mesa";

    persist.byStore.plaintext = [ ".cache/mepo/tiles" ];
    # ~/.cache/mepo/savestate has precise coordinates and pins: keep those private
    persist.byStore.private = [
      { type = "file"; path = ".cache/mepo/savestate"; }
    ];

    # enable geoclue2 and gpsd for location data.
    suggestedPrograms = [
      "geoclue2"
      # "gpsd"  #< not required, and mepo only uses it if geoclue is unavailable
    ];
  };

  # programs.mepo = lib.mkIf config.sane.programs.mepo.enabled {
  #   # enable location services (via geoclue)
  #   enable = true;
  #   # more precise, via gpsd ("may require additional config")
  #   # programs.mepo.gpsd.enable = true
  # };
}
