{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "jsoncons";
  version = "0.173.4";

  src = fetchFromGitHub {
    owner = "danielaparker";
    repo = "jsoncons";
    rev = "v${version}";
    hash = "sha256-Mf3kvfYAcwNrwbvGyMP6PQmk5e5Mz7b0qCZ6yi95ksk=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C++, header-only library for constructing JSON and JSON-like data formats";
    inherit (src.meta) homepage;
    license = licenses.boost;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
