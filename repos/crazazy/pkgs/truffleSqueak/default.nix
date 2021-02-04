{ graalvm11-ce, fetchurl, SDL2, autoPatchelfHook }:
graalvm11-ce.overrideAttrs (old: {
  srcs = old.srcs ++ [
    (fetchurl { 
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/20.2.0/trufflesqueak-installable-svm-java11-linux-amd64-20.2.0.jar";
      sha256 = "0jlxvr8gq99g7q6jcj1p58ijr1j02hdwcxw5672gzgmygln6x1vc";
    })];
  autoPatchelfIgnoreMissingDeps = true;
  unpackPhase = old.unpackPhase + ''
    unpack_jar ''${arr[5]}
    '';
  buildInputs = (old.buildInputs or []) ++ [ SDL2 autoPatchelfHook ];
  })

