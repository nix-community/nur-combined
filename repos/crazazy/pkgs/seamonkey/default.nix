{ lib, fetchzip, gtk2, gtk3, gdk-pixbuf, dbus-glib, xorg, stdenv, libpulseaudio, autoPatchelfHook, makeWrapper }:
stdenv.mkDerivation {
  name = "seamonkey";
  src = fetchzip {
    url = "https://archive.mozilla.org/pub/seamonkey/releases/2.53.13/linux-x86_64/en-US/seamonkey-2.53.13.en-US.linux-x86_64.tar.bz2";
    sha256 = "1k9kmnrib42z6agpmhh6clybf7zppmjs7qv9ip602gb0f6jpv2ba";
  };
  buildInputs = [
    xorg.libXdamage
    gtk2
    gtk3
    gdk-pixbuf
    makeWrapper
    dbus-glib
    xorg.libXt
    autoPatchelfHook
  ]; # ++ firefox-unwrapped.buildInputs;
  installPhase = ''
      mkdir -p $out/{bin,usr,lib,share/applications}
      cp -r $src/* $out/usr
      cp $out/usr/*.so* $out/lib
      makeWrapper $out/usr/seamonkey $out/bin/seamonkey --prefix LD_LIBRARY_PATH : ${libpulseaudio}/lib
      cp ${./seamonkey.desktop} $out/share/applications
  '';
  meta = with lib; {
    description = "Seamonkey browser.";
    license = with licenses; [mpl20];
    homepage = "https://www.seamonkey-project.org/";
    platforms = ["x86_64-linux"];
  };
}
