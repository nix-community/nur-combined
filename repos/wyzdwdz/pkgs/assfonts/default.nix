{ stdenv, lib, fetchzip }:

stdenv.mkDerivation rec {
  pname = "assfonts";
  version = "0.7.3";

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

  src = fetchzip {
    url =
      "https://github.com/wyzdwdz/assfonts/releases/download/v${version}/assfonts-v${version}-${arch}-Linux.tar.gz";
    hash = hashArch;
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin $out/share
    install -m 555 -D ./bin/assfonts -t $out/bin
    cp -r ./share $out
  '';

  meta = {
    description = "Subset fonts and embed them into an ASS subtitle (CLI version)";
    homepage = "https://github.com/wyzdwdz/assfonts";
    downloadPage = "https://github.com/wyzdwdz/assfonts/releases";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "assfonts";
    broken = false;
  };
}