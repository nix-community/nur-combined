{ batsTest, hpl, mpi, openssh } :

batsTest {
  name="hpl";

  outFile = [ "HPL.*" ];

  nativeBuildInputs = [ hpl mpi openssh ];

  # default needs at least 4 cpus
  TEST_NUM_CPUS=4;

  setupScript = ''
    if [ ! -f HPL.dat ]; then
      cp ${hpl}/share/hpl/HPL.dat .
    fi
  '';

  testScript = ''
    @test "HPL" {
      ${mpi}/bin/mpirun -np $TEST_NUM_CPUS ${hpl}/bin/xhpl > HPL.out
    }
  '';
}
