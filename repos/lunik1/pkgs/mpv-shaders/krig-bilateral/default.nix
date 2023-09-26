{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "krig-bilateral";
  version = "unstable-2023-09-26";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/bc10b47c6a4deef7cdca140830d6886e866663fb/KrigBilateral.glsl";
    sha256 = "sha256-oh4DOds2KUid4e4nqQhS3GMQyi743+HsGEdK3x8bfzA=";
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
