{ lib, stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "morisawa-biz-ud-mincho";
  version = "1.05";

  src = fetchzip {
    url =
      "https://github.com/googlefonts/morisawa-biz-ud-mincho/releases/download/v${version}/morisawa-biz-ud-mincho-fonts.zip";
    sha256 = "sha256-Vhw9QdzRmhoMgn2LSr8wZHopUk3ycP7W58ITSB6TFIA=";
  };

  installPhase = ''
    install -D -m 444 fonts/ttf/* -t $out/share/fonts/truetype/${pname}
  '';
}
