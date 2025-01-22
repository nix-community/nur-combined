{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-httplib";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "v${version}";
    hash = "sha256-mpHw9fzGpYz04rgnfG/qTNrXIf6q+vFfIsjb56kJsLg=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C++ header-only HTTP/HTTPS server and client library";
    homepage = "https://github.com/yhirose/cpp-httplib";

    license = licenses.mit;
    platforms = platforms.all;
  };
}
