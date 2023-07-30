{ nvsrcs, lib, gtk2, gtk3, gdk-pixbuf, dbus-glib, xorg, stdenv, libpulseaudio, autoPatchelfHook, makeWrapper, wrapGAppsHook }:
stdenv.mkDerivation {
  name = "seamonkey";
  inherit (nvsrcs.seamonkey) src version;
  buildInputs = [
    xorg.libXdamage
    gtk2
    gtk3
    gdk-pixbuf
    makeWrapper
    dbus-glib
    xorg.libXt
  ]; # ++ firefox-unwrapped.buildInputs;
  nativeBuildInputs = [
    wrapGAppsHook
    autoPatchelfHook
  ];
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
