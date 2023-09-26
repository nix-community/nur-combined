{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  gitUpdater,
}:
stdenvNoCC.mkDerivation rec {
  pname = "stats";
  version = "2.9.7";

  src = fetchurl {
    url = "https://github.com/exelban/stats/releases/download/v${version}/Stats.dmg";
    sha256 = "TfVm65Wa0fNZo1Pwd210vHI4t/xyfBdj1/LXqxtxRgY=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [undmg];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Stats.app $out/Applications

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/exelban/stats";
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "macOS system monitor in your menu bar";
    homepage = "https://github.com/exelban/stats";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = platforms.darwin;
    maintainers = with maintainers; [jpts];
    license = licenses.mit;
  };
}
