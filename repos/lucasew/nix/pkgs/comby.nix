{ pkgs, ... }:
with pkgs;
let
  binary = fetchurl {
    url = "https://github.com/comby-tools/comby/releases/download/1.0.0/comby-1.0.0-x86_64-linux";
    sha256 = "0lwiairbhllpsyfggbkhh0l6xs0da3kjm7bclvwm8g1sdgskm5f9";
  };
  pcre3-deb = stdenv.mkDerivation {
    name = "pcre3";
    src = fetchurl {
      url = "http://ftp.br.debian.org/debian/pool/main/p/pcre3/libpcre3_8.39-12_amd64.deb";
      sha256 = "1vkbrj06mmnj9zzsha61krp8ypzw2c7b75zw0h0s1c8jp13fm5jl";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir $out/dummy -p
      ${dpkg}/bin/dpkg-deb -xv $src $out/dummy
      mv $out/dummy/usr/* $out
      mv $out/dummy/lib/x86_64-linux-gnu/* $out/lib
      rm $out/dummy -rf
    '';
  };
  drv = stdenv.mkDerivation {
    name = "comby";
    version = "1.0.0";
    dontUnpack = true;
    src = binary;
    installPhase = ''
      mkdir -p $out/bin
      cp -r $src $out/bin/comby
      chmod +x $out/bin/comby
    '';
  };
in
buildFHSUserEnv {
  name = "comby";
  targetPkgs = pkgs: [
    sqlite
    zlib
    pcre-cpp
    pcre3-deb
  ];
  runScript = "${drv}/bin/comby";
}
