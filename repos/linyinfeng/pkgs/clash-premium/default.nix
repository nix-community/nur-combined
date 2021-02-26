{ system, stdenv, lib, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "0l1ml5yxnd7ccfhlwcmxxc8wp93gxq8pkc1xh261mr7adbk4sw23";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "01r2fqkqk5q5yg084dhi0hbh1nw01rczyd76aac7h2jp9fkyc9cp";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "1qzh4scf91fkbs69wyw51zm8nzvvwdx4qii4b2yjc264x3fh6ajj";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "0c6khiybakhvlizg53yfjfd9jylks7xdzswwpdfg7mk8wjvpp3wn";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  pname = "clash-premium";
  version = "2021.02.21";

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
