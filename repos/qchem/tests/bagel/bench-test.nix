{ lib, batsTest, bagel, openssh } :

batsTest {
  name = "bagel";

  auxFiles = [ ./bagel.inp ];

  outFiles = [ "*.out" ];

  nativeBuildInputs = [ bagel openssh ];

  testScript = ''
    @test "Run-Bagel" {
      ${bagel}/bin/bagel -np $TEST_NUM_CPUS ./bagel.inp > bagel.out
    }
  '';

  teardownScript = ''
    for f in *.archive *.molden *.log asd_*; do
      rm -f $f
    done
  '';
}
