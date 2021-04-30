{ batsTest, cfour, openssh } :

batsTest {
  name = "cfour";

  nativeBuildInputs = [ cfour openssh ];

  auxFiles = [
    ./ZMAT
    ./GENBAS
  ];

  outFile = [ "cfour.out" ];

  OMP_NUM_THREADS=2;
  CFOUR_NUM_CORES=2;

  testScript = ''
    @test "Run CFour" {
      xcfour > cfour.out
      grep "CCSD energy                             -151.36573" cfour.out
    }
  '';
}
