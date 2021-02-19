{ callPackage, tests } :

{
  threads ? 1,
  tasks ? 1
} :

callPackage ../../builders/benchmark.nix {
  test = tests.bagel-bench;

  subtests = [ "Run-Bagel" ];

  setupPhase = ''
    export TEST_NUM_CPUS=${toString tasks}
    export OMP_NUM_THREADS=${toString threads}
  '';
}
