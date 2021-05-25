{ batsTest, python3 } :

let
  python = python3.withPackages (p: with p; [pyscf]);

in batsTest {
  name = "pyscf";

  auxFiles = [ ./input.py ];
  outFile = [ "output" ];

  nativeBuildInputs = [ python ];

  testScript = ''
    @test "PySCF" {
      OMP_NUM_THREADS=$TEST_NUM_CPUS ${python}/bin/python3 input.py > output
      grep "Total energy of first excited state -75.2377" output
    }
  '';
}
