{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  pname = "paml";
  version = "4.9j";

  src = fetchzip {
    url = "http://abacus.gene.ucl.ac.uk/software/paml4.9j.tgz";
    hash = "sha256-pCnZxvG3V15HDCZKQwRZmoV1fCLptQnywit4b2YQ4iM=";
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
