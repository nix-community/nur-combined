{ lib, pkgs, ... }:
{
  sane.programs.gnome-weather = {
    buildCost = 1;

    packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.gnome-weather.overrideAttrs (base: {
      # default .desktop file is trying to do some dbus launch (?) which fails even *if* i install `gapplication` (glib.bin)
      postPatch = (base.postPatch or "") + ''
        substituteInPlace data/org.gnome.Weather.desktop.in.in \
          --replace-fail 'Exec=gapplication launch @APP_ID@' 'Exec=gnome-weather'
      '';
    }));

    sandbox.wrapperType = "inplace";  #< /share/org.gnome.Weather/org.gnome.Weather file refers to bins by full path
    sandbox.whitelistWayland = true;
    sandbox.net = "clearnet";

    persist.byStore.plaintext = [
      ".cache/libgweather"  # weather data (or maybe a http cache)
    ];

    gsettings."org/gnome/Weather" = with lib.gvariant; {
      # i have no idea the schema: i just exported this after manually entering a location
      locations = [
        (mkVariant
          (mkTuple [
            (mkUint32 2)
            (mkVariant
              (mkTuple [
                "Seattle"
                "KBFI"
                true
                [ (mkTuple [ 0.82983133145337307 (-2.134775231953554) ]) ]
                [ (mkTuple [ 0.83088509144255718 (-2.135097419733472) ]) ]
              ])
            )
          ])
        )
      ];
    };
  };
}
