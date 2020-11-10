{ lib, batsTest, bagel, openssh } :

let
  files = lib.remove "hf_read_mol_cart.json"
          (lib.remove "hf_read_mol_sph.json"
          (lib.mapAttrsToList (n: v: n)
          (lib.filterAttrs (n: v: v=="regular" )
          (builtins.readDir "${bagel}/share/tests/" ))));

in batsTest {
  name = "bagel";

  auxFiles = [ ./bagel.inp ];

  outFiles = [ "*.out" ];

  nativeBuildInputs = [ bagel openssh ];

  testScript = lib.concatStringsSep "\n" ( map ( x: ''
    @test "${x}" {
      if [ ${x} == "he_tzvpp_second_coulomb.json" ]; then
         skip "${x} is broken (memory leak)"
      fi

      ${bagel}/bin/bagel -np $TEST_NUM_CPUS ${bagel}/share/tests/${x} > ${x}.out
    }
  '') files) + ''

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
