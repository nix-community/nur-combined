{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "ssim-downscaler";
  version = "unstable-2022-05-15";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/6998ff663a135376dbaeb6f038e944d806a9b9d9/SSimDownscaler.glsl";
    sha256 = "sha256-FF3rw4DzwgWLHSkziQXSvIBgAxVtZ0skdFJ03S1QmQY=";
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
