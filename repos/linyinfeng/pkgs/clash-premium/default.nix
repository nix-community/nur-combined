{ system, stdenv, lib, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "1aq56r1f29qy55kh82a0dh6af07qapdf1if9r2sixqrn5fj277yq";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "0yz5a2001ip0m1s9fzg9r3i904bqssraw3s8hy9gambj1p5kiiwq";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "03blp6my60jg62miyp9v97gk7x9krm1fyb7jr4bc6xccgb27jh7p";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "00a39rahgcg4391rqwwbch5xqilycnlsr6a8zd4gjl7asbzl1rl2";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  pname = "clash-premium";
  version = "2021.05.08";

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
