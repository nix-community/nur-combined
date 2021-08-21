{ graalvm11-ce, fetchurl, SDL2, autoPatchelfHook }:
graalvm11-ce.overrideAttrs (old: {
  srcs = old.srcs ++ [
    (fetchurl {
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/21.2.0/trufflesqueak-installable-svm-java11-linux-amd64-21.2.0.jar";
      sha256 = "0znk3mm356wck6anqvgfaw154sskqgkvlyhxclsshh70vg4pq2s1";
    })];
  autoPatchelfIgnoreMissingDeps = true;
  unpackPhase = old.unpackPhase + ''
    unpack_jar ''${arr[5]}
    '';
  buildInputs = (old.buildInputs or []) ++ [ SDL2 autoPatchelfHook ];
  })
