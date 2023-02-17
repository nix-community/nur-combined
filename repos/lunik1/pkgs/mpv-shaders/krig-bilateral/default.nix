{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "krig-bilateral";
  version = "unstable-2022-05-30";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/7c151e0af2281ae6657809be1f3c5efe0e325c38/KrigBilateral.glsl";
    sha256 = "sha256-uIbPX59nIHeHC9wa1Mv1nQartUusOgXaEHQyA95BST8=";
  };

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/krig-bilateral/KrigBilateral.glsl

    runHook postInstall
  '';

  meta = with lib; {
    description = "KrigBilateral by Shiandow";
    homepage = "https://gist.github.com/igv/a015fc885d5c22e6891820ad89555637";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ lunik1 ];
    platforms = platforms.all;
  };
}
