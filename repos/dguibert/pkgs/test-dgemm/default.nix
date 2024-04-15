{
  stdenv,
  openblas,
}:
stdenv.mkDerivation {
  name = "test-dgemm-0.1";
  # https://gitlab.com/arm-hpc/packages/wikis/packages/dgemm
  # http://portal.nersc.gov/project/m888/apex/mt-dgemm_160114.tgz
  src = ./t_dgemm.c;
  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    set -x
    ''${CC:-gcc} -o $out/bin/test-dgemm $src -lopenblas
    set +x
  '';

  buildInputs = [openblas];
}
