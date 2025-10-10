{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "ssim-downscaler";
  version = "unstable-2024-09-05";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/38992bce7f9ff844f800820df0908692b65bb74a/SSimDownscaler.glsl";
    sha256 = "sha256-9G9HEKFi0XBYudgu2GEFiLDATXvgfO9r8qjEB3go+AQ=";
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
