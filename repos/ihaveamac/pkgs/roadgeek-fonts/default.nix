{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "roadgeek-fonts";
  version = "3.1";

  src = fetchzip {
    url = "https://github.com/sammdot/roadgeek-fonts/releases/download/${version}/RG2014-${version}0.zip";
    hash = "sha256-gI0f6896RSnjO51Y1oB2Ky+EnlRvaDO8BIpxzptaIiE=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "A set of fonts replicating various road sign typefaces.";
    homepage = "https://github.com/sammdot/roadgeek-fonts";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
