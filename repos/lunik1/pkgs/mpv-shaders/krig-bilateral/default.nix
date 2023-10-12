{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "krig-bilateral";
  version = "unstable-2023-10-12";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/e4d34ee29a5438add873710a1d5c3f9f00a96ec0/KrigBilateral.glsl";
    sha256 = "sha256-jHhE8MulnoChX2Hr0osWi6kZ+T4JLD/buF7DAwvq5Ag=";
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
