{ batsTest, stream-benchmark } :

batsTest {
  name = "stream";

  outFile = [ "*.txt" ];

  nativeBuildInputs = [ stream-benchmark ];

  testScript = ''
    @test "Stream" {
      OMP_NUM_THREADS=$TEST_NUM_CPUS ${stream-benchmark}/bin/stream > stream.out
    }
  '';
}
