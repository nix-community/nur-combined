{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "PEGTL";
  version = "3.2.5";

  src = fetchFromGitHub {
    owner = "taocpp";
    repo = "PEGTL";
    rev = "${version}";
    sha256 = "sha256-6BfWN8IsfAJxlhkFs8yCK0o2OfLI/acGXY+349MY9CY=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DPEGTL_BUILD_TESTS=OFF"
    "-DPEGTL_BUILD_EXAMPLES=OFF"
    "-DPEGTL_INSTALL_DOC_DIR=share/pegtl"
    "-DPEGTL_INSTALL_CMAKE_DIR=share/pegtl/cmake"
  ];

  meta = with lib; {
    description = "Zero-dependency C++ header-only parser combinator library.";
    homepage = "https://github.com/taocpp/PEGTL";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
