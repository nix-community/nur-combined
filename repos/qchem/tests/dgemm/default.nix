{ batsTest, lib, mt-dgemm, numactl
, size ? 500
, useNumactl ? false
, numactlParams ? "--interleave all"
} :

batsTest {
  name = "dgemm";

  outFile = [ "dgemm.out" ];

  nativeBuildInputs = [ mt-dgemm numactl ];

  testScript = ''
    @test "DGEMM" {
      OMP_NUM_THREADS=$TEST_NUM_CPUS \
        ${lib.optionalString useNumactl "${numactl}/bin/numactl ${numactlParams}"} \
        ${mt-dgemm}/bin/mt-dgemm ${toString size} > dgemm.out
    }
  '';
}
