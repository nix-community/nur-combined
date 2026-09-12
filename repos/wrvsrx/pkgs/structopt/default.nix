{
  stdenv,
  cmake,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "structopt";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "p-ranav";
    repo = "structopt";
    rev = "v${version}";
    hash = "sha256-AyWtJ+EyTN2LEXLM5OSQB3ITzqLLRoirzkWnjwLHOIA=";
  };
  nativeBuildInputs = [ cmake ];
}
