{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ttf-ms-win10";
  version = "unstable-2021-02-10";

  src = fetchFromGitHub {
    owner = "streetsamurai00mi";
    repo = pname;
    rev = "417eb232e8d037964971ae2690560a7b12e5f0d4";
    sha256 = "sha256-UwkHlrSRaXhfoMlimyXFETV9yq1SbvUXykrhigf+wP8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.ttf $out/share/fonts/truetype/
    install -D *.ttc $out/share/fonts/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/streetsamurai00mi/ttf-ms-win10";
    description = "Microsoft Windows 10 TrueType fonts for Linux";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
