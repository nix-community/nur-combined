{ buildFHSUserEnv, ocl-icd, makeWrapper, openssl, zlib, bzip2, stdenv, pkgs
, fetchurl, patchelf, linuxPackages, glibc }:

let
  fah = stdenv.mkDerivation rec {
    pname = "foldingathome";
    version = "7.5.1";
    buildInputs =
      [ ocl-icd makeWrapper openssl.out bzip2 zlib linuxPackages.nvidia_x11 ];

    installPhase = ''
      mkdir -p $out/bin $out/doc $out/etc $out/lib
      cp FAH* $out/bin
      cp *.md $out/doc
      cp *.xml $out/etc
    '';
    src = fetchurl {
      url =
        "https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.5/fahclient_7.5.1-64bit-release.tar.bz2";
      sha256 = "sha256:07sjqaxzn14ky8laiz7wxbvpvxdajs5xvgjl347g22y39cm5d8k9";
    };
  };

in buildFHSUserEnv {
  name = "FAHClient";
  runScript = "${fah}/bin/FAHClient";
  targetPkgs = pkgs: fah.buildInputs;
}
