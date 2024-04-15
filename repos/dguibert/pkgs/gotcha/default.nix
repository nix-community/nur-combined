{
  stdenv,
  fetchFromGitHub,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "gotcha";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "GOTCHA";
    rev = "refs/tags/${version}";
    sha256 = "sha256-Qll2anWdV4jRFrSzxfqM5sMw7JndngJfeNFfttAaLm8=";
  };

  buildInputs = [cmake];
}
