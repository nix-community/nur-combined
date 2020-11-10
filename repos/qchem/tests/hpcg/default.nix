{ batsTest, openmpi, openssh, hpcg
# Local sizes
, sizes ? [ 16 16 16 ]
# Minumum runtime in seconds
# The offically published
# results require at least 1800 s
, runTime ? 120
} :

batsTest {
  name = "hpcg";

  outFile = [ "*.txt" ];

  nativeBuildInputs = [ openmpi openssh hpcg ];

  testScript = ''
    @test "HPCG" {
      ${openmpi}/bin/mpirun -np $TEST_NUM_CPUS \
        ${hpcg}/bin/xhpcg ${toString sizes} ${toString runTime}
    }
  '';
}
