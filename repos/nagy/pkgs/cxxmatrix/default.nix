{ stdenv, lib, config, fetchFromGitHub, pkgs, ... }:

stdenv.mkDerivation rec {
  pname = "cxxmatrix";
  version = "unstable-2020-11-28";

  src = fetchFromGitHub {
    owner = "akinomyoga";
    repo = pname;
    rev = "93e505c82f06b67d610a14eff1bce9812ab203c5";
    sha256 = "1dxmq6hnhas6hbp1ayzk9hzhhpchkdmh5gh2x6vyj0qvgckwncpz";
  };

  outputs = [ "out" "man" ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "C++ Matrix: The Matrix Reloaded in Terminals";
    homepage = "https://github.com/akinomyoga/cxxmatrix";

    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
