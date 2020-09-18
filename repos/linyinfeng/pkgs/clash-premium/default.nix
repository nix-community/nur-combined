{ system, stdenv, fetchurl }:

let
  clashSystems = {
    "aarch64-linux" = "linux-armv8";
    "i686-linux" = "linux-386";
    "x86_64-darwin" = "darwin-amd64";
    "x86_64-linux" = "linux-amd64";
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  name = "clash-premium-${version}";
  version = "2020.08.16";

  src = fetchurl {
    url = "https://github.com/Dreamacro/clash/releases/download/premium/clash-${clashSystem}-${version}.gz";
    sha256 = "sha256-WCt47oTqoGBvVL6l677ymoQfj00N7P8QXoEGiuWQn/E=";
  };

  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/clash-premium.gz
    gzip --decompress $out/bin/clash-premium.gz
    chmod +x $out/bin/clash-premium
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/Dreamacro/clash;
    description = "Close-sourced pre-built Clash binary with TUN support and more";
    license = licenses.unfree;
    platforms = attrNames clashSystems;
  };
}
