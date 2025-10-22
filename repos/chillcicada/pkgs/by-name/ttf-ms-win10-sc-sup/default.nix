{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "ttf-ms-win10-sc-sup";
  version = "unstable-2025-06-03";

  src = fetchFromGitHub {
    owner = "chillcicada";
    repo = "ttf-ms-win10-sc-sup";
    rev = "f5d2ef2c84e8979b322563a53ea3adb5ab995176";
    sha256 = "sha256-gIMRE1jOEtskRzXGdUr6DRXghpMdM37NtoEJsC80/MQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.ttf $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/chillcicada/ttf-ms-win10-sc-sup";
    description = "Microsoft Windows 10 TrueType fonts (Simplified Chinese Supplemental fonts)";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
