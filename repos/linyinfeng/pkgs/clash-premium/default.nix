{ system, stdenv, lib, fetchurl }:
let
  clashSystems = {
    "aarch64-linux" = {
      system = "linux-armv8";
      sha256 = "043kak9sb3dfldrkbb3cr3yi8rsqq1x8k1iqrmwckfd3cmz7kpcd";
    };
    "i686-linux" = {
      system = "linux-386";
      sha256 = "09vrbgkijyz6hs4666llp3ab969gaxbramkhf9mwqz08krhkwv7z";
    };
    "x86_64-darwin" = {
      system = "darwin-amd64";
      sha256 = "130m2glqclysc9yrc6bsac5fm0zlw905y96hqs0nw84i68bv18q1";
    };
    "x86_64-linux" = {
      system = "linux-amd64";
      sha256 = "1akxsbib4fdkapl82pcihy2w69s22fb5p19n5j4vxxrhzq7887k1";
    };
  };
  clashSystem = clashSystems.${system};
in
stdenv.mkDerivation rec {
  pname = "clash-premium";
  version = "2021.03.10";

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
