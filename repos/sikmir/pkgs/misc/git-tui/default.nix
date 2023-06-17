{ lib, stdenv, fetchFromGitHub, cmake, ftxui, subprocess }:

stdenv.mkDerivation rec {
  pname = "git-tui";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "git-tui";
    rev = "v${version}";
    hash = "sha256-RogDZeDgC7HanPd0I+BuU9CShUzaIqvH1R7/I1tAtG4=";
  };

  patches = [ ./subprocess.patch ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ ftxui subprocess ];

  meta = with lib; {
    description = "Collection of human friendly terminal interface for git";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
