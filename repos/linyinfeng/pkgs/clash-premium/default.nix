{ system, stdenv, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "0r7lmjws0v9656z7185cyibvqgfz0iq354jdqyms43vmhdc40f2b";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "00g1v43arr5viry3m1f4zs38s1skw03pdglnprmn9aw105dm95a2";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "1r37pv3n0qn55bhs5sgdjch67bwy3xvjzzq5f0m0w5nqz156pmgh";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "0qsyvcijdslf67gdd8xyyj3hbbarkkzb9jrs6paamzxbh4zs0xya";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  name = "clash-premium-${version}";
  version = "2020.11.20";

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
