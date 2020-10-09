{ system, stdenv, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "1hgj9nsyi4bqba3mvd0p5y89hnvszzg1mg29r92wxa95bjmx33h9";
    };
    "i686-linux" =
      {
        system = "linux-386";
        sha256 = "024nmvs742b5a3p9bsyyxpqb88fz0pbwil2809sr9kn2pbssy8zi";
      };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "1a27pmmrq480xqnzgb8xhilg4v3k47c1mkwfa5qxbi2c976mcnk0";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "0xygagwa2nxchbwncqqh3xid9n87g0kb5c2hinav0ls3azamjn2l";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  name = "clash-premium-${version}";
  version = "2020.10.09";

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

  meta = with stdenv.lib; {
    homepage = https://github.com/Dreamacro/clash;
    description = "Close-sourced pre-built Clash binary with TUN support and more";
    license = licenses.unfree;
    platforms = attrNames clashSystems;
  };
}
