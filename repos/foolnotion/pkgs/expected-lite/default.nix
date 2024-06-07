{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "expected-lite";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "martinmoene";
    repo = "expected-lite";
    rev = "v${version}";
    sha256 = "sha256-8Lf+R7wC7f2YliXqhR6pwVVSLZ6qheu7YOV5jHc0Cjc=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A single-file header-only library for objects that either represent a valid value or an error that you can pass by value..";
    homepage = "https://github.com/martinmoene/expected-lite";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
