{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "expected-lite";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "martinmoene";
    repo = "expected-lite";
    rev = "v${version}";
    sha256 = "sha256-d3lFpi62QPZKVt/QeBV7MoH3QltSg5dsUI3dIUArPpA=";
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
