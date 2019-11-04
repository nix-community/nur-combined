{ stdenv, fetchFromGitHub, fetchurl, cmake }:

let
  cmake_dep = if stdenv.lib.versionOlder cmake.version "3.15" then
    cmake.overrideAttrs (o: rec {
      name = "${pname}-${version}";
      pname = "cmake";
      version = "3.15.4";

      src = fetchurl {
        url = "${o.meta.homepage}files/v${"3.15"/* majorVersion */}/cmake-${version}.tar.gz";
        # from https://cmake.org/files/v3.15/cmake-3.15.4-SHA-256.txt
        sha256 = "8a211589ea21374e49b25fc1fc170e2d5c7462b795f1b29c84dd0e984301ed7a";
      };

      # XXX: use patches used by provided cmake, should work if ~3.14+
    })
    else cmake;
in
stdenv.mkDerivation rec {
  pname = "zps";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "orhun";
    repo = pname;
    rev = "refs/tags/${version}";
    sha256 = "0qmf85j62ychjb5vclc9l6f5sg8wyfxkrzhf8jl5aq71v8gzaxba";
  };

  nativeBuildInputs = [ cmake_dep ];

  meta = with stdenv.lib; {
    description = "Small utility for listing and reaping zombie processes";
    homepage = "https://github.com/orhun/zps";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dtzWill ];
  };
}
