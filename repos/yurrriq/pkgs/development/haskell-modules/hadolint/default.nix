{ mkDerivation, aeson, base, bytestring, directory, dlist, fetchFromGitHub
, filepath, gitrev, hpack, hspec, HUnit, language-docker
, optparse-applicative, parsec, ShellCheck, split, stdenv, text
, yaml
}:
mkDerivation rec {
  pname = "hadolint";
  version = "1.6.5";
  src = fetchFromGitHub {
    owner = "hadolint";
    repo = pname;
    rev = "v${version}";
    sha256 = "0byz9x5v4clah48j5i8x78dm2csi1z4hdlgy1fk8mssxzy8k1pmz";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson base bytestring dlist language-docker parsec ShellCheck split
    text
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base directory filepath gitrev language-docker optparse-applicative
    parsec yaml
  ];
  testHaskellDepends = [
    aeson base bytestring hspec HUnit language-docker parsec ShellCheck
    split
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/hadolint/hadolint";
  description = "Dockerfile Linter JavaScript API";
  license = stdenv.lib.licenses.gpl3;
  maintainers = with stdenv.lib.maintainers; [ yurrriq ];
}
