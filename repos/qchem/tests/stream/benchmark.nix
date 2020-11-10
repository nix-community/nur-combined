{ callPackage, lib, qc-tests } :

{
  threads ? 1
} :

callPackage ../../builders/benchmark.nix {
  test = qc-tests.stream;

  setupPhase = ''
    export TEST_NUM_CPUS=${toString threads}
    export OMP_NUM_THREADS=1
  '';

  collectExtra = ''
    values=$(grep -A4 Function stream.out | sed '1d' | awk '{ print $2 }' | tr '\n' ' ')
    echo "stream $TEST_NUM_CPUS $values" >> bandwidth
  '';
}
