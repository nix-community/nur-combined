{ lib, fetchzip, gtk2, gtk3, gdk-pixbuf, dbus-glib, xorg, stdenv, autoPatchelfHook }:
stdenv.mkDerivation {
  name = "seamonkey";
  src = fetchzip {
    url = "https://archive.mozilla.org/pub/seamonkey/releases/2.53.9.1/linux-x86_64/nl/seamonkey-2.53.9.1.nl.linux-x86_64.tar.bz2";
    sha256 = "16dzrknaln1cidjvq9z4d6rkv5pzi4c4305ky0vi0mpkf4r4l21w";
  };
  buildInputs = [
    xorg.libXdamage
    gtk2
    gtk3
    gdk-pixbuf
    dbus-glib
    xorg.libXt
    autoPatchelfHook
  ]; # ++ firefox-bin.buildInputs;
  installPhase = ''
      mkdir -p $out/{bin,usr,lib}
      cp -r $src/* $out/usr
      cp $out/usr/*.so* $out/lib
      ln -s $out/usr/seamonkey $out/bin
  '';
  meta = with lib; {
    description = "Seamonkey browser. Uses the dutch version right now";
    license = with licenses; [mpl20];
    homepage = "https://www.seamonkey-project.org/";
    platforms = ["x86_64-linux"];
  };
}
