{ callPackage, lib, qc-tests } :

{
  threads ? 1
, size ? 1000
, useNumactl ? false
, numactlParams ? "--interleave all"
} :

callPackage ../../builders/benchmark.nix {
  test = qc-tests.dgemm.override { inherit size useNumactl numactlParams; };

  setupPhase = ''
    export TEST_NUM_CPUS=${toString threads}
    export OMP_NUM_THREADS=1
  '';

  collectExtra = ''
    val=$(grep 'GFLOP/s rate' dgemm.out | awk '{ print $3 }')
    echo "DGEMM $TEST_NUM_CPUS ${toString size} $val" >> gflops
  '';
}
