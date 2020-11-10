{ callPackage, qc-tests } :

{
  threads ? 1,
  tasks ? 1
} :

callPackage ../../builders/benchmark.nix {
  test = qc-tests.cp2k;
  subtests = [ "dbcsr" "bench_dftb" "H2O-gga" ];
  setupPhase = ''
    export TEST_NUM_CPUS=${toString tasks}
    export OMP_NUM_THREADS=${toString threads}
  '';
}
