{ stdenv, lib, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "cxxmatrix";
  version = "unstable-2021-10-18";

  src = fetchFromGitHub {
    owner = "akinomyoga";
    repo = pname;
    rev = "87f1fb028caee28ff793550edfdf940c5def0385";
    sha256 = "0mb2jxja60nvv210z4pjizkflfccpkiykxxdfvcggxivydnq7vyi";
  };

  outputs = [ "out" "man" ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "C++ Matrix: The Matrix Reloaded in Terminals";
    homepage = "https://github.com/akinomyoga/cxxmatrix";

    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "cxxmatrix";
  };
}
