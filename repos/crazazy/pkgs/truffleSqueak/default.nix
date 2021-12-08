{ graalvm17-ce, fetchurl, SDL2, autoPatchelfHook }:
graalvm17-ce.overrideAttrs (old: {
  srcs = old.srcs ++ [
    (fetchurl {
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/21.3.0/trufflesqueak-installable-java17-linux-amd64-21.3.0.jar";
      sha256 = "0f7jnya2n0pwqf2sdna8m01wf8csmqlni695wmk66xbn1ac36g5r";
    })];
  autoPatchelfIgnoreMissingDeps = true;
  unpackPhase = old.unpackPhase + ''
    unpack_jar ''${arr[5]}
    '';
  buildInputs = (old.buildInputs or []) ++ [ SDL2 autoPatchelfHook ];
  })
