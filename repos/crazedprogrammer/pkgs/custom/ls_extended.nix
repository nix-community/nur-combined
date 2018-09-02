{ stdenv, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation rec {
  name = "ls-extended-${version}";
  version = "2018-06-12";

  src = fetchFromGitHub {
    owner = "Electrux";
    repo = "ls_extended";
    rev = "9e479063d0ce16a62c6e67c122eb95deb0380827";
    sha256 = "14596mpbpd6rzk72xccpfk3qlha8msqf0y1znap5rlkzviqc14pp";
  };

  patches = [ ./ls_extended.patch ];

  buildPhase = "bash ./build.sh";
  installPhase = ''
    mkdir -p $out/bin
    install -m 755 bin/ls_extended $out/bin/ls_extended
  '';

  meta = with stdenv; {
    description = "ls with coloring and icons ";
    home = https://github.com/Electrux/ls_extended;
    license = lib.licenses.bsd3;
  };
}
