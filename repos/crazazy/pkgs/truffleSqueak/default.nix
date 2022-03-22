{ graalvm17-ce, fetchurl, SDL2, autoPatchelfHook }:
graalvm17-ce.overrideAttrs (old: {
  srcs = old.srcs ++ [
    (fetchurl {
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/22.0.0/trufflesqueak-installable-java17-linux-amd64-22.0.0.jar";
      sha256 = "0a7jdb7vgx3vn3axwkbja4y8dp0gns28azr7764ljx8ysbg54rx5";
    })];
  autoPatchelfIgnoreMissingDeps = true;
  unpackPhase = old.unpackPhase + ''
    unpack_jar ''${arr[5]}
    '';
  buildInputs = (old.buildInputs or []) ++ [ SDL2 autoPatchelfHook ];
  })
