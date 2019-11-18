{ stdenv, python, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "mesh";
  src = fetchFromGitHub {
    owner = "plasma-umass";
    repo = "Mesh";
    rev = "c5b954e14ba4ddca7951e3d6ff3b6da7bdfc8543";
    sha256 = "sha256:0bm69f5k5bafi2d5wq9vlag8399x6615yng4ql4fmddvgbydqms6";
    fetchSubmodules = true;
  };
  buildInputs = [ python ];

  preBuild = ''
    sed -i "s|PREFIX = .*|PREFIX = $out|;s/ldconfig//" Makefile GNUmakefile
    mkdir -p $out/lib
  '';
  enableParallelBuild = true;
}
