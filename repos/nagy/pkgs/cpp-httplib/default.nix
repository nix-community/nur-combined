{ stdenv, lib, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-httplib";
  version = "0.8.9";

  src = fetchFromGitHub {
    owner = "yhirose";
    repo = "cpp-httplib";
    rev = "v${version}";
    sha256 = "0sa6a2iwj0hm0ym2hpdf4qzq7vf0q6n7i626b5i7i1hfvln42k9s";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C++ header-only HTTP/HTTPS server and client library";
    homepage = "https://github.com/yhirose/cpp-httplib";

    license = licenses.mit;
    maintainers = [  ];
    platforms = platforms.all;
  };
}
