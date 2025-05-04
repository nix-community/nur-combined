{ lib
, stdenvNoCC
, fetchurl
, ...
} @ args :

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-wenkai-gb";
  version = "1.511";
  src = fetchurl {
    url = "wget https://gh.llkk.cc/https://github.com/lxgw/LxgwWenkaiGB/releases/download/v${version}/lxgw-wenkai-gb-v1.511.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    mv *.ttf $out/share/fonts/truetype
    
    runHook postInstall
  '';
}
