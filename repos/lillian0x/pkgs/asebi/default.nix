{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  pname = "asebi";
  version = "1.011";

  src = fetchzip {
    url = "https://ss1.xrea.com/metasta.s602.xrea.com/asebimin.zip";
    hash = "sha256-FGbG9X18X4FUj++uVNTOO/KppbvWfM+BuPIJHAMzXSI=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    find . -type f -name "*.ttf" -exec install -Dm444 -t $out/share/fonts/truetype {} +
    find . -type f -name "*.otf" -exec install -Dm444 -t $out/share/fonts/opentype {} +

    runHook postInstall
  '';

  meta = {
    description = "Asebi Mincho - Another Japanese font";
    downloadPage = "https://metasta.github.io/asebi/";
    homepage = "https://metasta.github.io/asebi/";
    license = lib.licenses.ipa;
    platforms = lib.platforms.all;
  };
}
