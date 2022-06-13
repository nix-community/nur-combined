{ graalvm17-ce, fetchurl, SDL2, autoPatchelfHook }:
graalvm17-ce.overrideAttrs (old: {
  srcs = old.srcs ++ [
    (fetchurl {
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/22.1.0/trufflesqueak-installable-svm-java11-linux-amd64-22.1.0.jar";
      sha256 = "02n4qp3jv7bwm3yadcryflmmabm42n9fsm1l1hmcj62kzrflpg9i";
    })];
  autoPatchelfIgnoreMissingDeps = true;
  buildInputs = (old.buildInputs or []) ++ [ SDL2 autoPatchelfHook ];
  })
