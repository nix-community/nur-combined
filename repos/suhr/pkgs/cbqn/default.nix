{ stdenv, lib, fetchFromGitHub, bootstrapped ? true, ripgrep }:

let
  libBQN = fetchFromGitHub {
    owner = "mlochbaum";
    repo = "bqn";
    rev = "3f7bab449929fbe396d4d842db0cdc0a36b5433f";
    sha256 = "sha256-RQL8oPy/UuOoiFnQi8jCAQGguCYqA74ysSZf9VgPupQ=";
  };

  bytecode = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "b1ebca430a766f5020ca2d229f0d736ed30e0174";
    sha256 = "sha256-nz3rjZnwDRdoskh1urEexSFOLWbSwpfxhp/6GPjqIio=";
  };

  src = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "fab1ffadf50af8a8fd4037ae68bbfaf7171b3ebc";
    sha256 = "sha256-hJ6u2As++lPH00umPlQSAjNs1bwDycjM6xEddUJmp/M=";
  };

  generic = { useBytecode ? false, bqn ? null, fullTestSuite ? true }:
    # Either use bytecode, or have bqn specified.
    assert (bqn != null) == !useBytecode;

    stdenv.mkDerivation rec {
      pname = "cbqn" + lib.optionalString useBytecode "-bytecode";
      version = "unstable-2021-09-22";

      inherit src;
      patches = lib.optional useBytecode ./generated.patch;
      nativeBuildInputs = [ bqn ];
      checkInputs = lib.optional fullTestSuite ripgrep;

      buildPhase = (if useBytecode then ''
        echo "Copying bytecode from bootstrap"
        cp ${bytecode}/src/gen/* src/gen/
      '' else ''
        echo "Generating bytecode..."
        bqn ./genRuntime ${libBQN}
      '') + ''
        sed -i 's|/usr/bin/env bash|${stdenv.shell}|' makefile
        make
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp BQN $out/bin
        ln -s $out/bin/BQN $out/bin/bqn
      '';

      doCheck = true;
      checkPhase = ''
        # Implement a very rudimentary smoke test
        echo "↕4" | ./BQN | grep "0 1 2 3"
      '' + lib.optionalString fullTestSuite ''
        ./BQN ${libBQN}/test/this.bqn | rg --passthru "All passed!"
      '';

      meta = with lib; {
        description = "An APL-like programming language";
        maintainers = with maintainers; [ synthetica ];
        platforms = with platforms; all;
        license = licenses.isc;
        homepage = "https://mlochbaum.github.io/BQN/";
      };
    };

  phase1 = generic { useBytecode = true; fullTestSuite = false; };
  phase2 = generic { bqn = phase1; };
  phase3 = generic { bqn = phase2; };
in
  if bootstrapped then phase3 else phase1
