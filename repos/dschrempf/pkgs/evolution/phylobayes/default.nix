{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "phylobayes";

  # # Parallel version.
  # version = "1.8c";
  # src = fetchFromGitHub {
  #   owner = "bayesiancook";
  #   repo = "pbmpi";
  #   rev = "v${version}";
  #   sha256 = "sha256-M62YxCC/eLAmhyzTOiPJoAvSy9Pzsr3t71IB4y8Td/Y=";
  # };

  # Sequential version.
  version = "4.1e";
  src = fetchFromGitHub {
    owner = "bayesiancook";
    repo = "phylobayes";
    rev = "v${version}";
    sha256 = "sha256-iWRfGo90Ni/piNLJceesSAG3ZIppR/F+c36k9KGRJzI=";
  };

  sourceRoot = "source/sources";
  patches = [ ./progsdir.patch ];
  patchFlags = [ "-p0" ];


  executables = [
    "ancestral"
    "bf"
    "bpcomp"
    "cvrep"
    "pb"
    "ppred"
    "readcv"
    "readdiv"
    "readpb"
    "stopafter"
    "subsample"
    "sumcv"
    "tracecomp"
    "tree2ps"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${builtins.concatStringsSep " " executables} $out/bin
  '';

  meta = with lib; {
    description = "Phylogenetic reconstruction using infinite mixtures";
    # Git repository: https://github.com/bayesiancook/phylobayes.
    homepage = "http://www.atgc-montpellier.fr/phylobayes/";
    license = null;
    maintainers = with maintainers; [ dschrempf ];
  };
}
