{
  mkDerivation,
  base,
  base64,
  lib,
  text,
  source,
}:
mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base
    base64
    text
  ];
  homepage = "https://github.com/wrvsrx/osc52";
  license = lib.licenses.mit;
  mainProgram = "osc52";
}
