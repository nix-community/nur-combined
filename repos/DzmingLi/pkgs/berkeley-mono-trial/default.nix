{
  lib,
  stdenvNoCC,
  fetchurl
}:

let
  trialLicense = {
    shortName = "berkeley-graphics-trial";
    fullName = "Berkeley Graphics Trial Font License";
    url = "https://usgraphics.com/static/legal/licenses/trial-license.6945159bcae5.pdf";
    free = false;
  };
in
stdenvNoCC.mkDerivation {
  pname = "berkeley-mono-trial";
  version = "2.004";

  src = fetchurl{
    url="https://github.com/DzmingLi/nur-packages/releases/download/berkeley-mono-trial-2.004/BerkeleyMonoTrial-Regular.fixed.otf";
    hash="sha256-EX3mTWei8pzm8Aag5lU38BHVX/xLb0ddqyKjtXjK9C4=";
  };
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 "$src" \
      "$out/share/fonts/opentype/BerkeleyMonoTrial-Regular.otf"

    runHook postInstall
  '';


  meta = {
    description = "Seven-day evaluation build of Berkeley Mono";
    homepage = "https://usgraphics.com/catalog/FX-050";
    downloadPage = "https://usgraphics.com/catalog/FX-050";
    license = trialLicense;
    platforms = lib.platforms.all;
    hydraPlatforms = [ ];
    maintainers = with lib.maintainers; [ brsvh ];
  };
}
