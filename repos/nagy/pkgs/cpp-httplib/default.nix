{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-httplib";
  version = "0.10.5";

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "v${version}";
    hash = "sha256-Xff5eCv22irrjK7tEGizrL7gXwFpZGYVzu6PAopk7nM=";
  };

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    # version detection seems to be broken
    substituteInPlace CMakeLists.txt \
             --replace '${"$"}{_httplib_version}' ${version}
  '';

  meta = with lib; {
    description = "A C++ header-only HTTP/HTTPS server and client library";
    homepage = "https://github.com/yhirose/cpp-httplib";

    license = licenses.mit;
    platforms = platforms.all;
  };
}
