{ callPackage, tests } :

{
  threads ? 1,
  tasks ? 1
} :

callPackage ../../builders/benchmark.nix {
  test = tests.nwchem;
  subtests = [ "Run-nwchem" ];
  setupPhase = ''
    TEST_NUM_CPUS=${toString tasks}
    OMP_NUM_THREADS=${toString threads}
  '';
}
