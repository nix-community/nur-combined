{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "paml";
  version = "4.10.6";

  src = fetchFromGitHub {
    owner = "abacus-gene";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ivmLgR/o+xnXA4Ac1GwSlR1MM5lDFlkQKXyl46clvQY=";
  };

  sourceRoot = "source/src";

  installPhase = ''
    mkdir -p $out/bin
    cp baseml basemlg chi2 codeml evolver infinitesites mcmctree pamp yn00 $out/bin/
  '';

  meta = with lib; {
    description = "Phylogenetic analysis with maximum likelihood";
    homepage = "http://abacus.gene.ucl.ac.uk/software/paml.html";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dschrempf ];
  };

  # nativeBuildInputs = [ ];
  # buildInputs = [ ];
  # propagatedBuildInputs = [ ];
}
