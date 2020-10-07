{ system, stdenv, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "1jpam0jwi842s0sbfx90fr6hz6c7b7gs7h4w3plzfj809s4d6dqx";
    };
    "i686-linux" =
      {
        system = "linux-386";
        sha256 = "0vpxhqrbwdf1h32q93gb2j1ph00hl9hp1wdgdfzablj76mj9b87a";
      };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "15xg1n3cmwarkcq81y3b77hzsqawlj4ng2lc5mi4iwdsdm2r206f";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "115rzndvhkdfh7z5hvi42zghg0yda0wvmj2ayiyih58n2dwmhscl";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  name = "clash-premium-${version}";
  version = "2020.09.27";

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
