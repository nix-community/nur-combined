{ stdenv, fetchzip, lib, atk, glib, pango, gdk-pixbuf, gtk3, cairo
, freetype, fontconfig, dbus, libXi, libXcursor, libXdamage, libXrandr, libXcomposite
, libXext, libXfixes, libXrender, libX11, libxcb, nss, udev, nspr
, alsa-lib, cups, expat, at-spi2-atk, at-spi2-core, libxshmfence
, libdrm, libxkbcommon, mesa }:

let
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc gtk3 atk glib pango gdk-pixbuf cairo freetype fontconfig dbus
    libXi libXcursor libXdamage libXrandr libXcomposite libXext libXfixes libxcb
    libXrender libX11 nss nspr alsa-lib cups expat udev 
    at-spi2-atk at-spi2-core libxshmfence libdrm libxkbcommon mesa
  ];

in
stdenv.mkDerivation rec {
  pname = "intiface-desktop";
  version = "27.0.0";

  src = fetchzip {
    url = "https://github.com/intiface/intiface-desktop/releases/download/v${version}/intiface-desktop-${version}-linux-x64.tar.gz";
    sha256 = "sha256-jEMPAuEBrY9zv6p/7WzsY+gxmL3NP+jLutglvXG+BOY";
  };

  installPhase = ''
    mkdir -p "$out/bin" "$out/usr/lib"
    cp -r $src "$out/usr/lib/intiface-desktop"
    chmod 777 "$out/usr/lib/intiface-desktop/intiface-desktop"

    ln -sf "$out/usr/lib/intiface-desktop/intiface-desktop" "$out/bin/intiface-desktop"
    chmod +x "$out/bin/intiface-desktop"

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}:$src:\$ORIGIN" \
      "$out/usr/lib/intiface-desktop/intiface-desktop"
  '';

  dontPatchELF = true;
  meta = with lib; {
    description = "Sex hardware hub";
    homepage    = "https://intiface.com/";
    license     = licenses.bsd3;
    platforms   = [ "x86_64-linux" ];
  };
}
