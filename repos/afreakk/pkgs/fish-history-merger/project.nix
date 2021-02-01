{ mkDerivation, base, containers, stdenv, fetchFromGitHub }:
mkDerivation {
  pname = "fish-history-merger";
  version = "0.1.0";
  src = fetchFromGitHub {
    rev = "8d08848aad5171ede58788148a9507c452dbb18f";
    owner = "afreakk";
    repo = "fish-history-merger";
    sha256 = "1vq25i4l4ydddpa8nypfqzim6hpj3b0vggrh7kg7q8ximc7ykfy8";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [ base ];
  executableHaskellDepends = [ base containers ];
  testHaskellDepends = [ base ];
  license = stdenv.lib.licenses.bsd3;
}
