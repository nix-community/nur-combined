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
, ...
}:

let
    pkgVersionStr = "3.3.0";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "domination";
  version = pkgVersionStr;

  src = fetchurl {
    url = "https://vipaks.com/upload/iblock/59a/4cpheqpr2gae3ol91q0rib21a16mph6o/Domination%20Client%20${pkgVersionStr}-Linux-deb.zip";
    sha256 = "sha256-Yw0i4bcPo4nw38FznoV/uM4jrjyb10Bv7e2PBvQQ5v8=";
  };

  nativeBuildInputs = [
    dpkg
    patchelf
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
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
    unzip
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "domination-client";
      type = "Application";
      terminal = false;
      desktopName = "Domination Client";
      comment = finalAttrs.meta.description;
      icon = "domination-client";
      exec = "domination-client %u";
      categories = [ "Utility" ];
      startupWMClass = "Domination Client";
    })
  ];

  unpackPhase = ''
    unpackFile $src
    dpkg-deb -x *.deb .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/Domination/Client,share/applications,share/icons}
    cp -r "./opt/Domination Client/resources/." "$out/opt/Domination/Client"
    cp -r ./usr/share/icons/. $out/share/icons

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/domination-client \
        --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ libsecret stdenv.cc.cc.lib ]}" \
        --add-flags $out/opt/Domination/Client/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}"
  '';

  preFixup = ''
    addAutoPatchelfSearchPath "$out/opt/Domination/Client"
    autoPatchelf $out
  '';

  meta = with lib; {
    description = "Приложение позволяет подключать неограниченное количество видеосерверов Domination, одновременно просматривать с них видео в режиме 'реального' времени и архива.";
    homepage = "https://vipaks.com";
    license = {
      fullName = "License agreement for Domination Client";
      url = "https://vipaks.com/upload/iblock/45d/4asg9sfrruyjmynpqwyyjxluyzdgjxvp/%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE_%D0%BA%D0%BB%D0%B8%D0%B5%D0%BD%D1%82_Linux_3.3.0.pdf";
      free = false;
    };
    platforms = [ "x86_64-linux" ];
  };
})