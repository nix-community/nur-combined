{
  graphviz,
  fetchurl,
  jre,
  lib,
  makeBinaryWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kroki";
  version = "0.25.0";

  src = fetchurl {
    url = "https://github.com/yuzutech/kroki/releases/download/v${finalAttrs.version}/kroki-standalone-server-v${finalAttrs.version}.jar";
    hash = "sha256-G8BWxunuqRJ+NsLeZ8LWQ0xVoZvgoxwQvgobOjd5tiw=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildCommand = ''
    		mkdir -p $out/lib/kroki
    		cp $src $out/lib/kroki/kroki.jar

    		mkdir -p $out/bin
    		makeWrapper ${jre}/bin/java $out/bin/kroki \
    			--argv0 kroki \
    			--add-flags "-DKROKI_DOT_BIN_PATH=${graphviz}/bin/dot" \
    			--add-flags "-jar $out/lib/kroki/kroki.jar"
    	'';

  doInstallCheck = false;

  meta = {
    description = "Creates diagrams from textual descriptions";
    homepage = "https://kroki.io";
    license = lib.licenses.mit;
    mainProgram = "kroki";
    maintainers = with lib.maintainers; [ wwmoraes ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
})
