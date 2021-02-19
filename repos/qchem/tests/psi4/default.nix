{ batsTest, psi4 } :

batsTest {
  name = "psi4";

  auxFiles = [ ./input ];
  outFile = [ "output" ];

  nativeBuildInputs = [ psi4 ];

  testScript = ''
    @test "PSI4" {
      OMP_NUM_THREADS=$TEST_NUM_CPUS ${psi4}/bin/psi4 -i input -o output
      grep "Final energy is    -76.235085" output
    }
  '';
}
