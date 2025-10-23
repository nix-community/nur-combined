{
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  dbus-glib,
  alsa-lib,
  pciutils,
  pipewire,
  fetchurl,
  stdenv,
  config,
  libva,
  xorg,
  curl,
  gtk3,
  lib,
  ...
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);
in
  stdenv.mkDerivation rec {
    pname = "waterfox-bin";

    inherit (info) version;

    src = fetchurl {
      url = "https://cdn1.waterfox.net/waterfox/releases/${version}/Linux_x86_64/waterfox-${version}.tar.bz2";
      inherit (info) hash;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      xorg.libXtst
      dbus-glib
      alsa-lib
      gtk3
    ];

    runtimeDependencies = [
      libva.out
      pciutils
      curl
    ];

    appendRunpaths = [
      (lib.getLib pipewire)
    ];

    buildPhase = let
      policies =
        {
          DisableAppUpdate = true;
        }
        // config.firefox.policies or {};
    in ''
      mkdir -p $out/{bin,lib/waterfox}
      cp -r * $out/lib/waterfox

      mkdir $out/lib/waterfox/distribution
      ln -s $out/lib/waterfox/waterfox $out/bin/waterfox
      # echo '${builtins.toJSON {inherit policies;}}' > $out/lib/waterfox/distribution/policies.json

      for i in 16 32 48 64 128
      do
        mkdir -p "$out/share/icons/hicolor/$(echo $i)x$(echo $i)/apps"
        ln -s $out/lib/waterfox/browser/chrome/icons/default/default$i.png "$out/share/icons/hicolor/$(echo $i)x$(echo $i)/apps/waterfox.png"
      done
    '';

    desktopItems = makeDesktopItem {
      name = "Waterfox";
      exec = "waterfox %U";
      desktopName = "Waterfox";
      genericName = "Web Browser";
      icon = "waterfox";
      mimeTypes = [
        "application/vnd.mozilla.xul+xml"
        "application/xhtml+xml"
        "text/html"
        "text/xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupNotify = true;
      startupWMClass = "waterfox";
      terminal = false;
      categories = ["Network" "WebBrowser"];
      actions = {
        new-private-window = {
          exec = "waterfox --private-window %U";
          name = "New Private Window";
        };
        new-window = {
          exec = "waterfox --new-window %U";
          name = "New Window";
        };
        profile-manager-window = {
          exec = "waterfox --ProfileManager";
          name = "Profile Manager";
        };
      };
    };

    passthru = {
      binaryName = "waterfox";
      libName = "waterfox";
      inherit gtk3;

      alsaSupport = true;
      pipewireSupport = true;
    };

    meta = {
      description = "Fast and Private Web Browser";
      homepage = "https://www.waterfox.net/";
      license = lib.licenses.mpl20;
      maintainers = ["BandiTheDoge" "Prinky"];
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
