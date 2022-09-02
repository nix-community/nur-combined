{ lib, stdenv, fetchFromGitHub, pkg-config, curl, SDL2, SDL2_image }:

stdenv.mkDerivation rec {
  pname = "sdlmap";
  version = "2014-02-09";

  src = fetchFromGitHub {
    owner = "jhawthorn";
    repo = "sdlmap";
    rev = "0baa8fb4472751c28bfe8b063070ea8b2d459224";
    hash = "sha256-W09WzCKmuMjV1L2c1bvlBCmNvXxYgGNU/MLtu6TTsIg=";
  };

  patches = [ ./tile.patch ./Makefile.patch ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ curl SDL2 SDL2_image ];

  installPhase = "install -Dm755 sdlmap -t $out/bin";

  meta = with lib; {
    description = "A SDL + libcurl OpenStreetMap viewer";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
