{ stdenv
, fetchurl
, lib
, dpkg
, autoPatchelfHook
, wrapGAppsHook

  # buildInputs
, at-spi2-atk
, at-spi2-core
, libXScrnSaver
, libappindicator-gtk3
, libdrm
, libglvnd
, libxkbcommon
, libxshmfence
, mesa
, xorg
, libX11
, nss
, nspr
, alsa-lib
, xdg-user-dirs

  # runtimeDependencies
, systemd
, libnotify
, libdbusmenu
}:

stdenv.mkDerivation rec {
  pname = "cider";
  version = "1.5.1-beta.30";
  src = fetchurl {
    url = "https://github.com/ciderapp/cider-releases/releases/download/v${version}/cider_${version}_amd64.deb";
    sha256 = "sha256-YBeewANk8T+IJtjqadYQiQFMjUcfzIzByQJm753LhyI=";
  };

  runtimeDependencies = [
    (lib.getLib systemd)
    libnotify
    libdbusmenu
  ];

  buildInputs = [
    alsa-lib
    libX11
    libXScrnSaver
    libappindicator-gtk3
    libdrm
    libglvnd
    libxkbcommon
    libxshmfence
    mesa
    nspr
    nss
    xdg-user-dirs
    xorg.libxcb
    autoPatchelfHook
    dpkg
    wrapGAppsHook
  ];
  unpackPhase = "dpkg-deb -x $src .";

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib,bin}
    mv usr/share $out/share
    mv opt/Cider $out/lib/Cider

    # $STRIP $out/lib/Cider/cider
    ln -s $out/lib/Cider/cider $out/bin/cider
    ln -s libGLESv2.so $out/lib/Cider/libGLESv2.so.2

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland }}"
    )

    # Fix the desktop link
    substituteInPlace $out/share/applications/cider.desktop \
      --replace /opt/Cider/cider $out/bin/cider
  '';

  meta = with lib; {
    homepage = "https://cider.sh/";
    description = "A new cross-platform Apple Music experience based on Electron and Vue.js written from scratch with performance in mind.";
    license = with licenses; [ agpl3 ];
    maintainers = with maintainers; [ congee ];
    platforms = [ "x86_64-linux" ];
  };
}
