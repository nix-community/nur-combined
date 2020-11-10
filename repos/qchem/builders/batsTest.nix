{ stdenvNoCC, lib, bats, writeShellScript, writeTextFile
, makeSetupHook
, overrideDontRun ? false
} :

{ name ? "batsTest"
# The bats test script
, testScript ? ""
# setup script code, executed at the end of setup phase
, setupScript ? ""
# teardown/cleanu code exectuted after each test
, teardownScript ? ""
# Files required for the test
, auxFiles ? []
# Place the test in the output, do not run the test
, dontRun ? overrideDontRun
# default number of CPUs to use (TEST_NUM_CPUS)
, numCpus ? 2
# File name patters to copy to out
, outFile ? []
# Some commonly required variables
, OMP_NUM_THREADS ? 1
# Allow more CPUs than are available
, OMPI_MCA_rmaps_base_oversubscribe ? 1
# UCX fails in sandbox
, OMPI_MCA_btl ? "self,vader"
, OMPI_MCA_pml ? "ob1,v,cm"
# Place all inputs (packages here)
, nativeBuildInputs ? []
, ...
}@attrs :

let
  rest = builtins.removeAttrs attrs [
    "name"
    "phases"
    "testScript"
    "nativeBuildInputs"
    "OMP_NUM_THREADS"
    "OMPI_MCA_rmaps_base_oversubscribe"
    "OMPI_MCA_btl"
    "OMPI_MCA_pml"
  ];

  batsTest = writeTextFile {
    name = name + ".bats";
    executable = true;
    text = ''
      #!${bats}/bin/bats
      setup () {

        # Make sure TEST_NUM_CPUS is defined
        # even if we run standalone
        if [ -z "$TEST_NUM_CPUS" ]; then
          TEST_NUM_CPUS=${toString numCpus}
        fi
        ${setupScript}
        SECONDS=0
      }

      teardown () {
        echo $SECONDS > "''${BATS_TEST_DESCRIPTION}.timing"

        ${teardownScript}
      }

      ${testScript}
    '';
  };

  # required for nix-shell mode
  # make phases callable from shell
  setupHook = makeSetupHook {
  } ./batsTest.sh;


in stdenvNoCC.mkDerivation ({
  inherit
    name
    auxFiles
    OMP_NUM_THREADS
    OMPI_MCA_rmaps_base_oversubscribe;


  phases = lib.optionals (!dontRun) [ "initPhase" "setupPhase" "runPhase" ]
    ++ [ "installPhase" ];

  nativeBuildInputs = nativeBuildInputs
    ++ [ setupHook ] ++ lib.optional (!dontRun) bats;

  # Required for sandbox env
  initPhase = ''
    mkdir -p tmp
    export TMPDIR=$PWD/tmp

    # provide a dummy home
    mkdir -p home
    export HOME=$PWD/home
  '';

  # Ensure aux files are in current directory
  setupPhase = ''
    echo "Copying aux files"
    for f in $auxFiles; do
      orgName=$(echo $f |  sed 's:${builtins.storeDir}/::;s/.\{32\}-//')
      echo " $orgName"
      cp $f $orgName
    done
  '';

  runPhase = ''
    bats ${batsTest} | tee report
  '';

  installPhase = ''
    mkdir -p $out

    cp ${batsTest} $out/testScript.bats
    chmod +x $out/testScript.bats

    if [ -f report ]; then
      cp report $out
      cp *.timing $out

      # copy results files
      for f in $outFile; do
        echo "copy $f"
        cp $f $out/
      done
    fi

    # Copy aux files to output
    for f in $auxFiles; do
      orgName=$(echo $f |  sed 's:${builtins.storeDir}/::;s/.\{32\}-//')
      echo "copy $orgName"
      cp $f $out/$orgName
    done
  '';


} // rest)

