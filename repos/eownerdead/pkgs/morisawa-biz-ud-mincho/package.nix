{ stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "morisawa-biz-ud-mincho";
  version = "1.06";

  src = fetchzip {
    url =
      "https://github.com/googlefonts/${pname}/releases/download/v${version}/morisawa-biz-ud-mincho-fonts.zip";
    sha256 = "sha256-TuNYguBCHkln8jbker/HxTNZS8cI1vJDRrT1PGmNSqE=";
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/truetype/ ./fonts/ttf/*

    runHook postInstall
  '';
}
