{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pi-token-speed";
  version = "0.12.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "gsanhueza";
    repo = "pi-token-speed";
    tag = finalAttrs.version;
    hash = "sha256-P6u5Og9SkEY6UQdx8IsV4xl4gBECUXHeofi6FxGDm/Q=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src package.json $out

    runHook postInstall
  '';

  meta = {
    description = "Pi extension to measure tokens per second via sliding window";
    homepage = "https://github.com/gsanhueza/pi-token-speed";
    downloadPage = "https://github.com/gsanhueza/pi-token-speed/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
