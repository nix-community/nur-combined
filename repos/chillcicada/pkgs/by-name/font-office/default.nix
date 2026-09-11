{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "font-office";
  version = "unstable-2026-04-27";

  src = fetchFromGitHub {
    owner = "chillcicada";
    repo = "fonts";
    rev = "e6e7c412f1a9aaa3718a2b031dff7ef585d6ada6";
    sha256 = "sha256-mn9rIM7AO2+8sxhF3+eciB1qYdnt7+oyScmmevGMCVM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.ttf $out/share/fonts/truetype/
    install -D *.ttc $out/share/fonts/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/chillcicada/fonts/tree/office";
    description = "Office fonts";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
