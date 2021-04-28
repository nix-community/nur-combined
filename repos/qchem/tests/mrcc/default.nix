{ batsTest, mrcc } :

batsTest {
  name = "mrcc";

  nativeBuildInputs = [ mrcc ];

  auxFiles = [ ./MINP ];

  outFile = [ "output" ];

  OMP_NUM_THREADS=2;

  testScript = ''
    @test "LCCSD(T)" {
      dmrcc > output
    }
  '';
}
