{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qstudio";
  version = "4.03";

  src = fetchfromgh {
    owner = "timeseries";
    repo = "qstudio";
    tag = finalAttrs.version;
    hash = "sha256-96E+exTt1Vebg2XL/c9c7gUFWYMkxjnAVumxg0U6Gpg=";
    name = "qstudio.jar";
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

  meta = {
    description = "SQL Analysis Tool";
    homepage = "https://www.timestored.com/qstudio/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
