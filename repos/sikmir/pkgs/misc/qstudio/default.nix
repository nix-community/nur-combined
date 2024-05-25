{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qstudio";
  version = "2.54";

  src = fetchfromgh {
    owner = "timeseries";
    repo = "qstudio";
    name = "qstudio.jar";
    hash = "sha256-NN2pkAjlwTbq25AafD06NMoAaOknW5nimya2zi+aMBQ=";
    version = finalAttrs.version;
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 $src $out/share/java/${finalAttrs.src.name}

    makeWrapper ${jre}/bin/java $out/bin/qstudio \
      --add-flags "-jar $out/share/java/${finalAttrs.src.name}"
  '';

  meta = with lib; {
    description = "SQL Analysis Tool";
    homepage = "https://www.timestored.com/qstudio/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
