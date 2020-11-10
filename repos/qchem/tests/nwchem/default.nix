{ batsTest, nwchem, openssh } :

batsTest {
  name = "nwchem";

  nativeBuildInputs = [ nwchem openssh ];

  auxFiles = [ ./nwchem.inp ];

  outFile = [ "nwchem.out" ];

  OMP_NUM_THREADS=2;

  testScript = ''
    @test "Run-nwchem" {
      nwchem $TEST_NUM_CPUS nwchem.inp > nwchem.out
    }

    @test "DFT Optimize" {
      grep -A6 'Optimization converged' nwchem.out | grep '\-195.322721'
    }

    @test "DFT Frequencies" {
      # Last NM in cm-1
      grep '39     3242' nwchem.out
    }
  '';
}
