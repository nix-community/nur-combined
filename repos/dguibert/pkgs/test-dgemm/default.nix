{ stdenv
, openblas
}:

stdenv.mkDerivation {
  name = "test-dgemm-0.1";
  src = ./t_dgemm.c;
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    gcc -o $out/bin/test-dgemm $src -lopenblas
  '';

  buildInputs = [ openblas ];
}
