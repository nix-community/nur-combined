{ stdenv, fetchurl, appimage-run, runtimeShell }:

stdenv.mkDerivation rec {
  pname = "ripcord";
  version = "0.4.22";

  src = fetchurl {
    url = "https://cancel.fm/dl/Ripcord-${version}-x86_64.AppImage";
    sha256 = "1sxh7g1p6f3j6mckn3v5c89404jn55cxms1m4xrf1l8j7ss9dchd";
  };

  buildInputs = [ appimage-run ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/Ripcord.AppImage
    echo "#!${runtimeShell}" > $out/bin/ripcord
    echo "${appimage-run}/bin/appimage-run $out/share/Ripcord.AppImage" >> $out/bin/ripcord
    chmod +x $out/bin/ripcord $out/share/Ripcord.AppImage
  '';

  meta = with stdenv.lib; {
    description = "Desktop chat client for Slack (and Discord)";
    homepage = "https://cancel.fm/ripcord/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
