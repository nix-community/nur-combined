{
  mkDerivation,
  base,
  cereal,
  fetchgit,
  hspec,
  hspec-discover,
  lens,
  lib,
  megaparsec,
  mtl,
  optparse-applicative,
  resourcet,
  rio,
  template-haskell,
  time,
  unix,
  unliftio,
}:
mkDerivation {
  pname = "kmonad";
  version = "0.4.1";
  src = fetchgit {
    url = "https://github.com/kmonad/kmonad";
    sha256 = "09w3pyb9sa7gxv9vi1wd3w6nyrbi6h28mzph6d901mvar6nand1p";
    rev = "3413f1be996142c8ef4f36e246776a6df7175979";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base
    cereal
    lens
    megaparsec
    mtl
    optparse-applicative
    resourcet
    rio
    template-haskell
    time
    unix
    unliftio
  ];
  executableHaskellDepends = [base];
  testHaskellDepends = [base hspec];
  testToolDepends = [hspec-discover];
  description = "Advanced keyboard remapping utility";
  license = lib.licenses.mit;
  mainProgram = "kmonad";
}