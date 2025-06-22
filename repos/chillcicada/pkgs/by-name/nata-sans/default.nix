{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nata-sans";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "dnlzqn";
    repo = "nata-sans";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zvwHOtD96EIy6GtN+uva64WmZgPUhsxGr8xBdSayR1Q=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D fonts/variable/*.ttf $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = {
    description = "Nata Sans is a grotesque typeface with a subtle humanist structure.";
    homepage = "https://github.com/dnlzqn/nata-sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
