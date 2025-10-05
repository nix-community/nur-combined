{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "macsvg";
  version = "1.2.0";

  src = fetchfromgh {
    owner = "dsward2";
    repo = "macSVG";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wlEFUzFQ9fnSjmsIrCDzRvSZmfcK9V+go6pNYJOqN+w=";
    name = "macSVG-v${lib.versions.majorMinor finalAttrs.version}.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv macSVG_v${
      lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor finalAttrs.version)
    }/*.app $out/Applications
    makeWrapper $out/{Applications/macSVG.app/Contents/MacOS/macSVG,bin/macsvg}
    runHook postInstall
  '';

  meta = {
    description = "An open-source macOS app for designing HTML5 SVG";
    homepage = "https://macsvg.org/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    mainProgram = "macsvg";
    skip.ci = true;
  };
})
