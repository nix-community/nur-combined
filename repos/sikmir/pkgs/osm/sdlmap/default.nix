{ lib, stdenv, fetchFromGitHub, curl, SDL2, SDL2_image }:

stdenv.mkDerivation rec {
  pname = "sdlmap";
  version = "2014-02-09";

  src = fetchFromGitHub {
    owner = "jhawthorn";
    repo = "sdlmap";
    rev = "0baa8fb4472751c28bfe8b063070ea8b2d459224";
    sha256 = "125hsfjbpvf2zia6702qgjyqsa84wnxxb75xskawif564b65cksv";
  };

  patches = [ ./tile.patch ];

  buildInputs = [ curl SDL2 SDL2_image ];

  installPhase = "install -Dm755 sdlmap -t $out/bin";

  meta = with lib; {
    description = "A SDL + libcurl OpenStreetMap viewer";
    homepage = src.meta.homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
