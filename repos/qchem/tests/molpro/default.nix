{ batsTest, molpro } :

batsTest {
  name = "molpro";
  auxFiles = [ ./molpro.inp ];

  outFile = [ "molpro.out" ];

  nativeBuildInputs = [ molpro ];

  testScript = ''
    @test "Run-Molpro" {
      ${molpro}/bin/molpro --launcher \
        "${molpro}/bin/mpiexec.hydra -iface lo
        -np $TEST_NUM_CPUS ${molpro}/bin/molpro.exe" \
        molpro.inp
    }

    @test "HF Energy" {
      grep '!RHF STATE 1.1 Energy' molpro.out | grep '\-113.9124931'
    }

    @test "CASSCF Energy" {
      grep '!MCSCF STATE 1.1 Energy' molpro.out | grep '\-113.8704585'
      grep '!MCSCF STATE 2.1 Energy' molpro.out | grep '\-113.6617828'
      grep '!MCSCF STATE 3.1 Energy' molpro.out | grep '\-113.5701796'
    }

    @test "OPTG Energy" {
      grep -A3 'Current geometry ' molpro.out | grep 'ENERGY=-113.8769466'
    }

    @test "CASPT2 Energy" {
      grep '!RSPT2 STATE 1.1 Energy' molpro.out | tail -1 | grep '\-114.3045096'
    }

    @test "MRCI Energy" {
      grep '!MRCI STATE 1.1 Energy' molpro.out | grep '\-114.2818399'
      grep '!MRCI STATE 2.1 Energy' molpro.out | grep '\-114.0268108'
    }
  '';
}

