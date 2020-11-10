{ callPackage, qc-tests } :

{
  threads ? 1
, mpiTasks ? 1
, mpiThreads ? 1
} :

assert threads == mpiTasks * mpiThreads;

callPackage ../../builders/benchmark.nix {
  test = qc-tests.molpro;

  subtests = [ "Run-Molpro" ];

  setupPhase = ''
    export TEST_NUM_CPUS=${toString mpiTasks}
    export OMP_NUM_THREADS=${toString mpiThreads}
  '';
}
