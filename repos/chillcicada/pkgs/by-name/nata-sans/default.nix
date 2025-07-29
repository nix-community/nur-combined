{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nata-sans";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "dnlzqn";
    repo = "nata-sans";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wgeZCLm18yE0bNuIUO3FOxBeYudilOZSLBLMoBVDSu0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.ttf $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = {
    description = "Nata Sans is a grotesque typeface with a subtle humanist structure.";
    homepage = "https://github.com/dnlzqn/nata-sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
