{ callPackage, qc-tests } :

{
  threads ? 1,
  tasks ? 1
} :

callPackage ../../builders/benchmark.nix {
  test = qc-tests.molcas;
  subtests = [ "Run-Molcas" ];
  setupPhase = ''
    TEST_NUM_CPUS=${toString tasks}
    OMP_NUM_THREADS=${toString threads}
  '';
}
