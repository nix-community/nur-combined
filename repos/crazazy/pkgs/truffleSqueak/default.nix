{ graalvm11-ce, fetchurl, SDL2, autoPatchelfHook }:
graalvm11-ce.overrideAttrs (old: {
  srcs = old.srcs ++ [
    (fetchurl { 
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/21.0.0/trufflesqueak-installable-svm-java11-linux-amd64-21.0.0.jar";
      sha256 = "0g66ziik6hqlzp6b7yg956l2cjr1gpbpyis4y9zi9g9mvhyffin3";
    })];
  autoPatchelfIgnoreMissingDeps = true;
  unpackPhase = old.unpackPhase + ''
    unpack_jar ''${arr[5]}
    '';
  buildInputs = (old.buildInputs or []) ++ [ SDL2 autoPatchelfHook ];
  })

