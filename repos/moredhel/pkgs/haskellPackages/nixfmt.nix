{ fetchFromGitHub, mkDerivation, alex, base, Earley, happy, parsec, pretty, stdenv
, text
}:
mkDerivation {
  pname = "nixfmt";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "Gabriel439";
    repo = "nixfmt";
    sha256 = "0f6kbcs9dzgah76l5ql1xd8qylw2v4iqswaa99krd6gibf1nh4pw";
    rev = "ae310b52a99e1fe41110e7ac07f6e477c612b32c";
    fetchSubmodules = false;
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base Earley parsec pretty text ];
  executableToolDepends = [ alex happy ];
  homepage = "https://github.com/Gabriel439/nixfmt#readme";
  description = "Auto-format Nix code";
  license = stdenv.lib.licenses.bsd3;
}
