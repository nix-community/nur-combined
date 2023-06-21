{ fetchurl, lib, stdenv, squashfsTools, xorg, alsa-lib, makeShellWrapper, wrapGAppsHook, openssl, freetype
, glib, pango, cairo, atk, gdk-pixbuf, gtk3, cups, nspr, nss_latest, libpng, libnotify
, libgcrypt, systemd, fontconfig, dbus, expat, ffmpeg_4, curlWithGnuTls, zlib, gnome
, at-spi2-atk, at-spi2-core, libpulseaudio, libdrm, mesa, libxkbcommon
, harfbuzz, spotify, spotify-adblock, spotifywm, deviceScaleFactor ? null
}: 

let
  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curlWithGnuTls
    dbus
    expat
    ffmpeg_4 
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libdrm
    libgcrypt
    libnotify
    libpng
    libpulseaudio
    libxkbcommon
    mesa
    nss_latest
    pango
    stdenv.cc.cc
    systemd
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXtst
    zlib
  ];
in
  spotify.overrideAttrs (prev: {
  installPhase = prev.installPhase + ''
    ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
    sed -i "s:^Name=Spotify.*:Name=Spotify-adblock:" "$out/share/spotify/spotify.desktop"
  '';
})
  
