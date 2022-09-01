{ lib, stdenv, fetchFromGitHub, cmake, curl }:

stdenv.mkDerivation rec {
  pname = "vectiler";
  version = "2021-06-30";

  src = fetchFromGitHub {
    owner = "karimnaaji";
    repo = pname;
    rev = "76e71c852b020fb5b877c0b03dfeb263a632df71";
    hash = "sha256-O21XTkKAKRVqc7iItT8MroxM6PtTDNCoEdXvkpnxWus=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ curl ];

  installPhase = ''
    install -Dm755 vectiler.out $out/bin/vectiler
  '';

  meta = with lib; {
    description = "A vector tile, terrain and city 3d model builder and exporter";
    homepage = "http://karim.naaji.fr/vectiler.html";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
