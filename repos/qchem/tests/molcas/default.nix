{ batsTest, molcas, openssh } :

batsTest {
  name = "molcas";
  auxFiles = [ ./molcas.inp ];

  outFile = [ "molcas.out" ];

  nativeBuildInputs = [ molcas openssh ];

  # MPI mode seems to be broken
  TEST_NUM_CPUS=1;

  # Use OpenMP
  OMP_NUM_THREADS=2;

  testScript = ''
    @test "Run-Molcas" {
      # Run on 2 CPUs to test parallelism
      env > env
      ${molcas}/bin/pymolcas -np $TEST_NUM_CPUS molcas.inp > molcas.out
    }

    @test "HF Energy" {
      grep 'Total SCF energy' molcas.out | grep '\-113.9192464'
    }

    @test "CASSCF Energy" {
      grep 'RASSCF root number  1' molcas.out | grep '\-113.9406226'
      grep 'RASSCF root number  2' molcas.out | grep '\-113.7941812'
      grep 'RASSCF root number  3' molcas.out | grep '\-113.5246366'
    }

    @test "CASPT2 Energy" {
      grep 'MS-CASPT2 Root  1' molcas.out | grep '\-114.3443192'
      grep 'MS-CASPT2 Root  2' molcas.out | grep '\-114.1969791'
      grep 'MS-CASPT2 Root  3' molcas.out | grep '\-113.9916607'
    }
  '';
}

