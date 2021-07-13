{ stdenv, lib, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "cxxmatrix";
  version = "unstable-2021-06-30";

  src = fetchFromGitHub {
    owner = "akinomyoga";
    repo = pname;
    rev = "b58c7e00588c46cd0cef6fef3205ccd814b51ba8";
    sha256 = "0n5zkzfv6ablkinvz1mvn2iaq1mzlv56izrqnp7hg10ckvp63szx";
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
