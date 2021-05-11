{ batsTest, lib, stdenvNoCC, cp2k, mpi, openssh } :

let
  # Copy test files from sources
  inp = stdenvNoCC.mkDerivation {
    name = "cp2k-tests";
    phases = [ "unpackPhase" "installPhase" ];

    src = cp2k.src;

    installPhase = ''
      mkdir -p $out
      cp -r benchmarks/QS_single_node/*.inp $out
    '';
  };

in batsTest {
  name="cp2k";

  # Required for mpi to run in sandboxed env
  nativeBuildInputs = [ openssh mpi cp2k ];

  auxFiles = [ ./oxole.inp ];

  outFile = [ "*.out" ];

  testScript = lib.concatStringsSep "\n" ( map (x: ''
    @test "${x}" {
      ${mpi}/bin/mpirun -np $TEST_NUM_CPUS ${cp2k}/bin/cp2k.psmp ${inp}/${x}.inp > ${x}.out
    }
  '') [ "dbcsr" "bench_dftb" "H2O-gga" ]) + ''

    @test "bench_dftb Energy" {
      grep 'ENERGY|' bench_dftb.out | grep '\-16687.6956289'
    }

    @test "H2O-gga Energy" {
      grep 'ENERGY|' H2O-gga.out | tail -1 | grep '\-1106.7588411'
    }

    @test "Threading and BLAS" {
      OMP_NUM_THREADS=2 ${mpi}/bin/mpirun -np 2 ${cp2k}/bin/cp2k.psmp oxole.inp > oxole.out
      grep "Total energy:                                               -41.131148" oxole.out
    }
  '';
}
