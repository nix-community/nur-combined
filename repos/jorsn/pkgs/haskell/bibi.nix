{ mkDerivation, base, containers, directory, fetchgit, filepath
, HDBC, HDBC-sqlite3, parsec, stdenv
}:
mkDerivation {
  pname = "bibi";
  version = "0.1";
  src = fetchgit {
    url = "https://github.com/patoline/hs-bibi";
    sha256 = "1z6x5l3irzfkik68d5ik7xlnng6m335xr0gwq189cvf0k2b04s1x";
    rev = "17b95439161b676fb72f21432c1ffac9d58f874d";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base containers HDBC HDBC-sqlite3 parsec
  ];
  executableHaskellDepends = [ directory filepath ];
  description = "A library to manipulate bibliography items used in TeX'";
  license = "GPL";

}
