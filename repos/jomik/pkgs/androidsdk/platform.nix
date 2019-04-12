{ lib, pkgs }:
{ api, rev, sha256 }:

pkgs.stdenv.mkDerivation rec {
  version = "${api}_r${lib.fixedWidthNumber 2 rev}";
  name = "android-sdk-platform-${version}";
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://dl-ssl.google.com/android/repository/platform-${version}.zip";
  };
  buildInputs = with pkgs; [ unzip ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/platforms/android-${api}
    mv -t $out/platforms/android-${api} ./*
  '';

  meta = {
    license = lib.licenses.unfree;
  };
}
