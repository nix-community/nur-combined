{ stdenv, fetchFromGitLab, autoreconfHook, yacc, bison, flex, swig, libtool
, perl, texlive }:
let
  latex = texlive.combine {
    inherit (texlive)
      scheme-basic collection-latexrecommended collection-fontsrecommended
      latexmk nag doublestroke mathabx tabulary stmaryrd doi todonotes biblatex
      metafont;
  };
in stdenv.mkDerivation {
  name = "spot";

  src = fetchFromGitLab {
    domain = "gitlab.lrde.epita.fr";
    owner = "spot";
    repo = "spot";
    rev = "8ac9684a69acbb987b88483ee9b50c23b959a410";
    sha256 = "sha256-yoZg1gw6XlGZVtT/dzXLKVhhlZ5ih/5oCCwGZBCXweQ=";
  };

  patchPhase = ''
    substituteInPlace Makefile.am --replace "DOC_SUBDIR = doc" ""
  '';

  configureFlags =
    [ "--disable-python" "--disable-doxygen" "--without-included-ltdl" ];

  enableParallelBuilding = true;

  buildInputs = [ autoreconfHook yacc bison flex swig libtool perl latex ];
}
