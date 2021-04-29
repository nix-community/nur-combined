{ batsTest, dalton } :

batsTest {
  name = "psi4";

  auxFiles = [ ./dalinp.dal ./molinp.mol ];
  outFile = [ "dalton.out" ];

  nativeBuildInputs = [ dalton ];

  testScript = ''
    @test "Dalton" {
      ${dalton}/bin/dalton -o dalton.out -omp 2 -N 1 dalinp molinp
      grep "@    Final HF energy:             -76.02689" dalton.out
    }
  '';
}
