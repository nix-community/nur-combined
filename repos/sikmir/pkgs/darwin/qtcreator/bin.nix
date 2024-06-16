{
  lib,
  stdenv,
  fetchfromgh,
  p7zip,
  makeWrapper,
  qtcreator,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtcreator-bin";
  version = "14.0.0";

  src = fetchfromgh {
    owner = "qt-creator";
    repo = "qt-creator";
    name = "qtcreator-macos-universal-${finalAttrs.version}.7z";
    hash = "sha256-+I4HqyTRY/1GtTYJ+4kJpXbIOnm6zkaYrOFexWDVBDM=";
    version = "v${finalAttrs.version}";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    p7zip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/Qt\ Creator.app/Contents/MacOS/Qt\ Creator,bin/qtcreator}
    runHook postInstall
  '';

  meta =
    with lib;
    qtcreator.meta
    // {
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      maintainers = [ maintainers.sikmir ];
      platforms = [ "x86_64-darwin" ];
      skip.ci = true;
    };
})
