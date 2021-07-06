{ system, stdenvNoCC, lib, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "14mk1n09lgsv704qwl43vlp214bvjiyhraynmly2knxhc0jvasa4";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "08aaafjzacdavpbgkgammp2ajfn58c0z7bv4ha6jmgpw2998wrfy";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "1csshjqgwl27w4v2pjsw7xl3y08paj5x5yg96hh3mfj4nhh5z0vs";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "1d6mq8qbkiz1f6fy91l2cdq32rk38kp479rf2ky73304a2rq2v9g";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenvNoCC.mkDerivation rec {
  pname = "clash-premium";
  version = "2021.07.03";

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
