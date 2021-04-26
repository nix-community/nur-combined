{ batsTest, turbomole } :

batsTest rec {
  name = "turbomole";

  auxFiles = [
    ./auxbasis
    ./basis
    ./control
    ./coord
    ./mos
  ];
  outFile = [
    "ridft.out"
    "ricc2.out"
  ];

  nativeBuildInputs = [ turbomole ];

  # Turbomole writes to its input files, yes.
  testScript = ''
    @test "RI-ADC2" {
      chmod +w auxbasis
      chmod +w basis
      chmod +w control
      chmod +w coord
      chmod +w mos
      ${turbomole}/bin/ridft -smpcpus 2 > ridft.out
      ${turbomole}/bin/ricc2 -smpcpus 2 > ricc2.out
      grep "HOMO-LUMO gap:    0.48876" ridft.out
      grep "frequency :   0.14623" ricc2.out
    }
  '';
}
