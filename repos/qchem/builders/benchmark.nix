{
  batsTest
, buildEnv
, writeShellScript
  # testDeriv to convert
, test
  # subtests to collect (timing)
, subtests ? []
  # setup for benchmark run (shell code)
, setupPhase ? ""
  # extra shell code to collect results
, collectExtra ? ""
} :

let
  testFiles = let
    batsDontRun = batsTest.override { overrideDontRun = true; };
  in test.override { batsTest = batsDontRun; };

  env = test: buildEnv {
    name = test.name + "env";
    paths = test.nativeBuildInputs;
  };

in writeShellScript (test.name + "-benchmark") ''
    # Prepare
    cp ${testFiles}/* .
    chmod +w *

    ${setupPhase}

    # Run
    nix-shell -p ${env test} --run ./testScript.bats > testScript.out

    # Collect
    touch res
    for i in ${if (builtins.length subtests > 0) then (toString subtests) else "*.timing"}; do
      i=$(echo $i | sed 's/\.timing$//')
      grep -e "^ok [0-9]\+ $i" testScript.out > /dev/null
      if [ $? == 0 ]; then
        echo "$i $TEST_NUM_CPUS $OMP_NUM_THREADS $(cat $i.timing)" >> res
      else
        echo "Test $i Failed!"
      fi
    done

    ${collectExtra}
  ''
