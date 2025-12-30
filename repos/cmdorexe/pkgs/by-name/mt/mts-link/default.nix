{ stdenv
, dpkg
, fetchurl
, autoPatchelfHook
, makeWrapper
, patchelf
, makeDesktopItem
, copyDesktopItems
, alsa-lib
, atk
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, mesa
, musl
, glib
, gtk3
, nspr
, nss
, pango
, requireFile
, systemd
, libxkbcommon
, xorg
, lib
, electron
, libGL
, libnotify
, libXScrnSaver
, xdg-utils
, util-linux
, unzip
, libsecret
, libva
, p7zip
, ...
}:

let
    pkgVersionStr = "latest";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mts-link";
  version = pkgVersionStr;
#  src = fetchurl {
#    url = "https://apps.webinar.ru/desktop/latest/mts-link-desktop.deb";
#    sha256 = "sha256-TkEcEr9GVqioc73+5qULGpjLlhnTN/WwnUnjmcu/Vwo=";
#  };
#  src = fetchurl {
#    url = "https://apps.webinar.ru/weteams/linkchats-desktop.appx";
#    sha256 = "sha256-0ErmAVkoOeU/ajQW1Pnyh6SmrRJTg0xFyfXWK0TcS5I=";
#  };
  src = fetchurl {
    url = "https://apps.webinar.ru/desktop/latest/mts-link-desktop.AppImage";
    sha256 = "sha256-jk7mEy4QpTiNBihE3kiiW51qHofjXTAEq2iT2pU8fzA=";
  };

  nativeBuildInputs = [
    dpkg
    patchelf
    autoPatchelfHook
    makeWrapper
    copyDesktopItems  # Add this
  ];

  buildInputs = [
    electron
    libsecret.dev
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    musl
    mesa
    glib
    gtk3
    nspr
    nss
    pango
    systemd
    libxkbcommon
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
    libnotify
    libXScrnSaver
    xdg-utils
    util-linux
    libsecret
    libGL
    stdenv.cc.cc.lib
    p7zip
    libva
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "mts-link";
      type = "Application";
      terminal = false;
      desktopName = "MTS Link";
      comment = "MTS Link desktop application based on Electron and React";
      icon = "mts-link";
      exec = "mts-link --no-sandbox %u";
      categories = [ "Office" "VideoConference" ];
      startupWMClass = "MTS Link";
      mimeTypes = [ "x-scheme-handler/wbnr" ];
    })
  ];


  unpackPhase = ''
    7z x $src
  '';

#    cp -r "./opt/MTS Link Meetings/." "$out/opt/MTS/Link"
#    cp -r ./usr/share/icons/. $out/share/icons
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/MTS/Link/resources,share/applications,share/icons}
    ls -la
    cp -r "./resources/." "$out/opt/MTS/Link/resources"

    runHook postInstall
  '';

#    ln -s $out/opt/MTS/Link/mts-link-meetings $out/bin/mts-link2
  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/mts-link \
        --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ libsecret stdenv.cc.cc.lib libva ]}" \
        --add-flags $out/opt/MTS/Link/resources/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"
  '';

  preFixup = ''
    addAutoPatchelfSearchPath "$out/opt/MTS/Link"
    autoPatchelf $out
  '';

  meta = with lib; {
    description = "MTS Link desktop application based on Electron and React";
    homepage = "https://webinar.ru";
    license = {
      fullName = "MTS Link";
      url = "";
      free = false;
    };
    platforms = [ "x86_64-linux" ];
  };
})