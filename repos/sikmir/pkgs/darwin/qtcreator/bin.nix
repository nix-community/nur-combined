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
  version = "15.0.1";

  src = fetchfromgh {
    owner = "qt-creator";
    repo = "qt-creator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-64pmcCvqBnohrmYw+VLUWskOhzmWd9aWZXzFhqG1I9o=";
    name = "qtcreator-macos-universal-${finalAttrs.version}.7z";
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
