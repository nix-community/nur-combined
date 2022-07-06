{ lib, stdenv, matrix-synapse, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "matrix-synapse-contrib";
  version = matrix-synapse.version;

  src = fetchFromGitHub rec {
    owner = "matrix-org";
    repo = "synapse";
    rev = "v${version}";
    sha256 = {
      "1.56.0" = "sha256-rzS2u5TkmwEb1cs7MwO/HrEmn1VHnrku9Q7Gw6CesOs=";
      "1.57.0" = "sha256-CRsBEt40j9kNxLipt2hczvlLC3KQVxRSSKJ5FoZbLJI=";
      "1.58.0" = "sha256-FF9FAo0LQqgOHkQ1WNBW/Q8Z5Wf4SOsvwtESNlfIVno=";
      "1.59.1" = "sha256-8YtBUossdvB5Gp9Ghs4sgf+fuz/jLxKMMHg9GdCvy+E=";
      "1.60.0" = "sha256-TgbIQ1hXewttY+5sbLeUH7ULQw9GUhoo2KZzN2t+FNw=";
      "1.61.0" = "sha256-er9alqTeC8WIaJyfgGn51peHepaMwF2+GiI5ARtp1RE=";
      "1.61.1" = "sha256-GNSWJf5bG1ZxsAX/d9gDXiBLXnE++mR6qi2mcdBy5Tk=";
    }.${version};
  };

  installPhase = ''
    cp -r contrib $out/
  '';
}
