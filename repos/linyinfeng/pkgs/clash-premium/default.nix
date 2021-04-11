{ system, stdenv, lib, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "0q2hs8xzk7gni2gw2lg99xs2s6022381rj3vjw0vxdvvy47lidzv";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "1qi3zwmsksjga4q0p8zavqqs89ipk0f9s4w0jrbhri36r2kmyhch";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "0wwm7si0x9s362j671b5mmh4dcbadi1gg2a50xcz190p9w34xcxf";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "1150gyjp23mbs68czm53i7cbfpqnk62f8hqi1na7hq6zraqx640h";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  pname = "clash-premium";
  version = "2021.04.08";

  src = fetchurl {
    url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-${clashSystem.system}-${version}.gz";
    sha256 = clashSystem.sha256;
  };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/clash-premium.gz
    gzip --decompress $out/bin/clash-premium.gz
    chmod +x $out/bin/clash-premium
  '';

  meta = with lib; {
    homepage = https://github.com/Dreamacro/clash;
    description = "Close-sourced pre-built Clash binary with TUN support and more";
    license = licenses.unfree;
    platforms = attrNames clashSystems;
  };
}
