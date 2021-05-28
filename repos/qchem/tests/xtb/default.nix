{ batsTest, lib, xtb, orca ? null } :

batsTest rec {
  name = "xtb";

  auxFiles = [ ./RuCO_6.xyz ];
  outFile = [ "xtb.out" ] ++ lib.lists.optional (orca != null) "xtb_orca.out";

  nativeBuildInputs = [ xtb ];

  # Turbomole writes to its input files, yes.
  testScript = ''
    @test "GFN2-XTB" {
      ${xtb}/bin/xtb RuCO_6.xyz --gfn 2 -u 2 --grad > xtb.out
      grep "GRADIENT NORM               0.2506" xtb.out
    }
  '' + lib.strings.optionalString (orca != null) ''
    @test "XTB-ORCA" {
      ${xtb}/bin/xtb RuCO_6.xyz --orca -u 2 --grad > xtb_orca.out
      grep "gradient norm              0.1158" xtb_orca.out
    }
  '';
}
