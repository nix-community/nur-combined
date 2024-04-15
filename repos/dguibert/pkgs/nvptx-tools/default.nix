{
  stdenv,
  fetchFromGitHub,
  perl,
  cudatoolkit,
}:
stdenv.mkDerivation {
  pname = "nvptx-tools";
  version = "2018-03-01";

  src = fetchFromGitHub {
    owner = "MentorEmbedded";
    repo = "nvptx-tools";
    rev = "5f6f343a302d620b0868edab376c00b15741e39e";
    sha256 = "sha256-XGEZle8I7vx5tldbt75cXjpohqXfCMNRZDlKsuaBVl0=";
  };

  buildInputs = [
    cudatoolkit
    perl
  ];
}
