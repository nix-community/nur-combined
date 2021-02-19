{ callPackage, lib, tests } :

{
  tasks ? 2
, sizes ? [ 16 16 16 ]
, runTime ? 30
} :

callPackage ../../builders/benchmark.nix {
  test = tests.hpcg.override { inherit sizes runTime; };

  setupPhase = ''
    export TEST_NUM_CPUS=${toString tasks}
    export OMP_NUM_THREADS=1
  '';

  collectExtra = ''
    outFile=$(ls -tr HPCG-Benchmark_*.txt | tail -1)
    bw=$(grep 'GB/s Summary::Raw Total B/W=' $outFile | sed 's/.*=//')
    gflops=$(grep 'HPCG result is VALID with a GFLOP/s rating' $outFile | sed 's/.*=//')

    echo "hpcg $TEST_NUM_CPUS ${toString sizes} $bw $gflops" >> gflops
  '';
}
