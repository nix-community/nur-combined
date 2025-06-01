{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "ttf-ms-win10-sc-sup";
  version = "unstable-2025-03-25";

  src = fetchFromGitHub {
    owner = "chillcicada";
    repo = "ttf-ms-win10-sc-sup";
    rev = "425fbc570a2e6eac6c9eeb852c2a8e946d4f2238";
    sha256 = "sha256-3FV7tE9xEteTv5rrvZcMgGw4wBAJa11vFiNnvwRJ4dw=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.{ttf,TTF} $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/chillcicada/ttf-ms-win10-sc-sup";
    description = "Microsoft Windows 10 TrueType fonts (Simplified Chinese Supplemental fonts)";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
