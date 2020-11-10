{ batsTest, mesa-qc } :

batsTest {
  name = "mesa";

  auxFiles = [ ./mesa.inp ];

  outFile = [ "mesa.out" ];

  nativeBuildInputs = [ mesa-qc ];

  testScript = ''
    @test "Run Mesa" {
      mesa
    }

    @test "SCF Energy" {
      grep -A1 'iter              energy' mesa.out | grep '\-1.123119131'
    }
  '';
}
