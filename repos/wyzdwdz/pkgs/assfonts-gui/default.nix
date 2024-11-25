{ stdenv, lib, appimageTools, fetchzip }:

appimageTools.wrapType2 rec {
  version = "0.7.3";
  pname = "assfonts-gui";
  name = "${pname}-${version}";

  arch =
    if stdenv.system == "x86_64-linux" then "x86_64"
    else if stdenv.system == "i686-linux" then "i686"
    else if stdenv.system == "aarch64-linux" then "aarch64"
    else if stdenv.system == "armv7l-linux" then "armhf"
    else abort ("Unsupported platform");

  hashArch =
    if stdenv.system == "x86_64-linux" then "sha256-rbo4PWJpNklGEPmN6/fsvcuH5v75c1zifI++rJKdhng="
    else if stdenv.system == "i686-linux" then "sha256-g8uB2h85w9vw6zRv3aYMCzWo/blDJ7jlGIrH4TLOpIo="
    else if stdenv.system == "aarch64-linux" then "sha256-Ee7EO9TO9Houhi8spGHsioQg1n4ii+qqh6+if6he/Ek="
    else if stdenv.system == "armv7l-linux" then "sha256-QDVlk0c+R1uEB8hCTDi1Eebegt2AzCcuBvHYVZq9Cds="
    else abort ("Unsupported platform");

  tarSrc = fetchzip {
    url =
      "https://github.com/wyzdwdz/assfonts/releases/download/v${version}/assfonts-v${version}-${arch}-Linux.tar.gz";
    hash = hashArch;
    stripRoot = false;
  };

  src = "${tarSrc}/assfonts-gui.AppImage";

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/assfonts-gui.desktop -t $out/share/applications
    mkdir -p $out/share/icons
    cp ${appimageContents}/usr/share/icons/icon.png $out/share/icons/assfonts-gui.png
  '';

  meta = {
    description = "Subset fonts and embed them into an ASS subtitle (GUI version)";
    homepage = "https://github.com/wyzdwdz/assfonts";
    downloadPage = "https://github.com/wyzdwdz/assfonts/releases";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "assfonts-gui";
    broken = false;
  };
}
