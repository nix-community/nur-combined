{ stdenv, fetchurl, appimage-run, runtimeShell }:

stdenv.mkDerivation rec {
  pname = "ripcord";
  version = "0.4.23";

  src = fetchurl {
    url = "https://cancel.fm/dl/Ripcord-${version}-x86_64.AppImage";
    sha256 = "0395w0pwr1cz8ichcbyrsscmm2p7srgjk4vkqvqgwyx41prm0x2h";
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
