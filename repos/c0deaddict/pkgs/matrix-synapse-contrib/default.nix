{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = "1.59.1"; # matrix-synapse.version;

  src = fetchFromGitHub rec {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = {
      "1.56.0" = "sha256-rzS2u5TkmwEb1cs7MwO/HrEmn1VHnrku9Q7Gw6CesOs=";
      "1.57.0" = "sha256-CRsBEt40j9kNxLipt2hczvlLC3KQVxRSSKJ5FoZbLJI=";
      "1.58.0" = "sha256-FF9FAo0LQqgOHkQ1WNBW/Q8Z5Wf4SOsvwtESNlfIVno=";
      "1.59.1" = "sha256-8YtBUossdvB5Gp9Ghs4sgf+fuz/jLxKMMHg9GdCvy+E=";
    }.${version};
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
