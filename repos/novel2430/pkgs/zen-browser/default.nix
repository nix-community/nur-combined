{ stdenv, lib, fetchurl, autoPatchelfHook, makeWrapper, copyDesktopItems, makeDesktopItem, writeText
, dbus-glib
, gtk3
, xorg
, nss
, systemd
, ffmpeg-headless
, libnotify
, zlib
, mesa
, libglvnd
, pciutils
, xdg-utils
, alsa-lib
, pipewire
, libpulseaudio
, udev
, libkrb5
, libva
, adwaita-icon-theme
, cups
, vulkan-loader
, sndio
, libjack2
, libcanberra-gtk3
# Option
, hunspell #spell
, hunspellDicts
, networkmanager
, speechd-minimal
}:
let
  pname = "zen-browser-bin";
  version = "1.17.6b";

  _pname = "zen-browser";

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
    hash = "sha256-IkewJI+fpECNu6LgIY5LRL7bnLlrV5Bo+tzwT1nQrM4=";
  };

  libs = [
    dbus-glib
    gtk3 
    nss
    systemd
    ffmpeg-headless
    libnotify
    libglvnd
    pciutils
    xdg-utils
    alsa-lib
    pipewire
    libpulseaudio
    udev
    libkrb5
    libva
    adwaita-icon-theme
    cups
    vulkan-loader
    sndio
    libjack2
    libcanberra-gtk3
    mesa
    zlib
    # Option
    hunspell
    hunspellDicts.en_US
    networkmanager
    speechd-minimal
    # X stuff
    xorg.libXt
    xorg.libX11
    xorg.libXext
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXrandr
    xorg.libXxf86dga
    xorg.libXxf86vm
  ];

  enterprisePolicies = {
    policies = {
      DisableAppUpdate = true;
      HomePage = {
        URL = "https://zen-browser.app/";
        Locked = false;
      };
      DNSOverHTTPS = {
        Enabled = true;
        Locked = false;
      };
    };
  };
  policiesJson = writeText "policies.json" (builtins.toJSON enterprisePolicies);
in
stdenv.mkDerivation{
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = libs;

  installPhase =''
    runHook preInstall

    mkdir -p $out/opt/zen
    cp -r ./* $out/opt/zen;

    # Icons
    for i in 16x16 32x32 48x48 64x64 128x128; do
      install -m 444 -D $out/opt/zen/browser/chrome/icons/default/default''${i/x*}.png $out/share/icons/hicolor/''$i/apps/${_pname}.png
      install -m 444 -D $out/opt/zen/browser/chrome/icons/default/default''${i/x*}.png $out/share/icons/hicolor/''$i/apps/zen.png
    done

    # policies.json
    mkdir -p $out/opt/zen/distribution
    cat ${policiesJson} >> $out/opt/zen/distribution/policies.json

    # wrapper
    makeWrapper $out/opt/zen/zen-bin $out/bin/${_pname} \
      --set MOZ_LEGACY_PROFILES 1 \
      --run "mkdir -p \$HOME/.config/zen-browser" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs} \
      --add-flags "-profile \$HOME/.config/zen-browser";

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "${pname}";
      desktopName = "Zen Browser";
      type = "Application";
      exec = "${_pname} %u";
      terminal = false;
      icon = "${_pname}";
      comment = "Experience tranquillity while browsing the web without people tracking you!";
      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "application/x-xpinstall"
        "application/pdf"
        "application/json"
      ];
      startupWMClass = "zen";
      categories = [ "Network" "WebBrowser" ];
      startupNotify = true;
      keywords = [
        "Internet"
        "WWW"
        "Browser"
        "Web"
        "Explorer"
      ];
      actions = {
        new-window = {
          name = "Open a New Window";
          exec = "${_pname} %u";
        };
        new-private-window = {
          name = "Open a New Private Window";
          exec = "${_pname} --private-window %u";
        };
        profilemanager = {
          name = "Open the Profile Manager";
          exec = "${_pname} --ProfileManager %u";
        };
      };
    })
  ];

  meta = with lib; {
    description = "User-friendly, useful, mods that increase usability can be added from the zen-mods mod store, a customizable browser, features that can be searched for in a browser for the end user, easy to use thanks to the shortcut key assignment feature, theme-store, frequently used progressive web apps, add-on apps, websites can be easily accessed thanks to the sidebar feature, can be viewed as a mobile page. container, work spaces, zen-mods, window management by creating multiple tab sections in a window, sidebar feature.";
    homepage = "https://zen-browser.app/";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = with licenses; [ mpl20 mit ];
  };
}
