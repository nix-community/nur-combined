{
  lib,
  stdenv,
  fetchfromgh,
  unzip,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "i18n-editor";
  version = "2.0.0-beta.1";

  src = fetchfromgh {
    owner = "jcbvm";
    repo = "i18n-editor";
    tag = finalAttrs.version;
    hash = "sha256-koJdCmcM9mH4D4JSyyi0i/zRCUeI6pYdMmS7SaC56aY=";
    name = "i18n-editor-${finalAttrs.version}.zip";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildInputs = [ jre ];

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 i18n-editor.jar -t $out/share/java

    makeWrapper ${jre}/bin/java $out/bin/i18n-editor \
      --add-flags "-jar $out/share/java/i18n-editor.jar"
  '';

  meta = {
    description = "GUI for editing your i18n translation files";
    homepage = "https://github.com/jcbvm/i18n-editor";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
