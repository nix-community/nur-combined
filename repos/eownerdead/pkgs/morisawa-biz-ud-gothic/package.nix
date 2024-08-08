{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "morisawa-biz-ud-gothic";
  version = "1.051";

  src = fetchzip {
    url = "https://github.com/googlefonts/${pname}/releases/download/v${version}/BIZUDGothic.zip";
    sha256 = "sha256-Rn9kKAxZdk1/0dT1Jh/V9bT/zKDCkLIjIjz3oGSiit8=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/truetype/ ./*

    runHook postInstall
  '';
}
