{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "ssim-downscaler";
  version = "unstable-2023-09-26";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/a408bcf3c34a43f29ea4cdc4fa282ce956be5363/SSimDownscaler.glsl";
    sha256 = "sha256-AEq2wv/Nxo9g6Y5e4I9aIin0plTcMqBG43FuOxbnR1w=";
  };

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/ssim-downscaler/SSimDownscaler.glsl

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://gist.github.com/igv/36508af3ffc84410fe39761d6969be10";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ lunik1 ];
    platforms = platforms.all;
  };
}
