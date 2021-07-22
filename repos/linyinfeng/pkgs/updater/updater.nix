{ mkDerivation, base, lib, nvfetcher }:
mkDerivation {
  pname = "updater";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base nvfetcher ];
  license = lib.licenses.mit;
}
