{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "tlx";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "tlx";
    repo = "tlx";
    rev = "v${version}";
    hash = "sha256-qH6gHPX1GdxMKbsrKeJpKOwRdPHVjPZGIWzcOX8HxwA=";
  };

  patchPhase = ''
    substituteInPlace misc/cmake/tlx.pc --replace-fail "includedir=\''${prefix}" "includedir="
    substituteInPlace misc/cmake/tlx.pc --replace-fail "libdir=\''${exec_prefix}" "libdir="
    substituteInPlace CMakeLists.txt --replace-fail "VERSION 2.8.12" "VERSION 3.15"
  '';

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Collection of C++ data structures, algorithms, and miscellaneous helpers";
    homepage = "https://github.com/tlx/tlx";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
