{ callPackage, lib, qc-tests
, hpl # this should be the same as in the test !!!
} :

{
  threads ? 1,
  tasks ? 4
# Process grid
, P ? 2, Q ? 2
# Problem sizes N
, sizes ? [ 2000 ]
# Block sizes NB
, blocks ? [ 200 ]
} :

assert P * Q == tasks;

callPackage ../../builders/benchmark.nix {
  test = qc-tests.hpl;


  setupPhase = ''
    export TEST_NUM_CPUS=${toString tasks}
    export OMP_NUM_THREADS=${toString threads}

    # Fix HPL.dat with our parameters
    sed '5s/.*/${toString (builtins.length sizes)}/;
         6s/.*/${toString sizes}/;
         7s/.*/${toString (builtins.length blocks)}/;
         8s/.*/${toString blocks}/;
         10s/.*/1/;
         11s/.*/${toString P}/;
         12s/.*/${toString Q}/;
         14s/.*/1/;
         15s/.*/1/;
         20s/.*/1/;
         21s/.*/2/' \
         ${hpl}/share/hpl/HPL.dat > HPL.dat
  '';

  collectExtra = ''
    # Collect GFlops values
    grep -e '^W[LR]' HPL.out >  gflops
  '';
}

