{ stdenv, lib, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "cxxmatrix";
  version = "unstable-2022-03-24";

  src = fetchFromGitHub {
    owner = "akinomyoga";
    repo = pname;
    rev = "f338ed434e3f759e9be9dd8e0212e9e4a895d2a9";
    sha256 = "sha256-XS9ms/sqBSQ5fzZvXNnC+HYvrK0T2EzgC/WdBhz9QOs=";
  };

  outputs = [ "out" "man" ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "The Matrix Reloaded in Terminals";
    homepage = "https://github.com/akinomyoga/cxxmatrix";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
