{ callPackage, lib, qc-tests } :

{
  threads ? 1
} :

callPackage ../../builders/benchmark.nix {
  test = qc-tests.qdng;


  setupPhase = ''
    export TEST_NUM_CPUS=${toString threads}
    export OMP_NUM_THREADS=1
  '';
}
