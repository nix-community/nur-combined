{ batsTest, qdng, octave } :

batsTest {
  name="qdng";

  auxFiles = [ ./qdng.inp ./geninp.m ];

  outFile = [ "qdng.out" ];

  nativeBuildInputs = [ qdng octave ];

  setupScript = ''
    ${octave}/bin/octave geninp.m

    # Spin up once to generate an optimal plan for fftw
    ${qdng}/bin/qdng -p $TEST_NUM_CPUS qdng.inp steps=1 > init
  '';

  teardownScript = ''
    rm *.op *.wf
    rm -r efs
  '';

  testScript = ''
    @test "QDng" {
      ${qdng}/bin/qdng -p $TEST_NUM_CPUS qdng.inp steps=500 > qdng.out
    }
  '';
}
