{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "consolas";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "misuchiru03";
    repo = "font-consolas-ttf";
    rev = finalAttrs.version;
    hash = "sha256-O1K2mi6saSrrTEvhECpsFMCKEtLeIk5Muh3XW5yD+mw=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 fonts/Consolas.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = {
    description = "Microsoft Consolas font";
    homepage = "https://github.com/misuchiru03/font-consolas-ttf";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
})
