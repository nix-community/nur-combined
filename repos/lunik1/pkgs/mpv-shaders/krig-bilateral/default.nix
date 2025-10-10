{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "krig-bilateral";
  version = "unstable-2023-10-26";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/038064821c5f768dfc6c00261535018d5932cdd5/KrigBilateral.glsl";
    sha256 = "sha256-ikeYq7d7g2Rvzg1xmF3f0UyYBuO+SG6Px/WlqL2UDLA=";
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
