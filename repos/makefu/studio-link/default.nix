{ stdenv, fetchurl, buildFHSUserEnv, writeTextFile, alsaLib, atk, cairo, cups
, dbus, expat, fontconfig, freetype, gcc, gdk_pixbuf, glib, gnome2, gtk2, nspr
, nss, pango, systemd, xorg, utillinuxMinimal, unzip, openssl, zlib, libjack2 }:

let
  libPath = stdenv.lib.makeLibraryPath [
    alsaLib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gcc.cc
    gdk_pixbuf
    glib
    gnome2.GConf
    gtk2
    nspr
    nss
    pango

    openssl
    zlib
    libjack2

    systemd
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
  ];
in
stdenv.mkDerivation rec {
  name = "studio-link-${version}";
  version = "17.03.1-beta";
  src = fetchurl {
    url = "https://github.com/Studio-Link-v2/backend/releases/download/v${version}/studio-link-standalone-linux.zip";
    sha256 = "1y21nymin7iy64hcffc8g37fv305b1nvmh944hkf7ipb06kcx6r9";
  };
  buildInputs = [ unzip ];
  phases = ["unpackPhase" "installPhase" "fixupPhase"];
  unpackPhase = ''
    unzip $src
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp studio-link-standalone $out/bin/studio-link
    chmod +x $out/bin/studio-link
  '';
  postFixup = ''
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) --set-rpath "${libPath}:\$ORIGIN" "$out/bin/studio-link"
  '';

  meta = with stdenv.lib; {
    homepage = https://studio-link.com;
    description = "Voip transfer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };
}
