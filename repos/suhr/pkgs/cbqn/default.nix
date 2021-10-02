{ stdenv, lib, fetchFromGitHub, bootstrapped ? true, ripgrep }:

let
  libBQN = fetchFromGitHub {
    owner = "mlochbaum";
    repo = "bqn";
    rev = "b3d68f730d48ccb5e3b3255f9010c95bf9f86e22";
    sha256 = "sha256-Tkgwz7+d25svmjRsXFUQq0S/73QJU+BKSNeGqpUcBTQ=";
  };

  bytecode = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "94bb312d20919f942eabed3dca33c514de3c3227";
    sha256 = "sha256-aFw5/F7/sYkYmxAnGeK8EwkoVrbEcjuJAD9YT+iW9Rw=";
  };

  src = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "3725bd58c758a749653080319766a33169551536";
    sha256 = "sha256-xWp64inFZRqGGTrH6Hqbj7aA0vYPyd+FdetowTMTjPs=";
  };

  generic = { useBytecode ? false, bqn ? null, fullTestSuite ? true }:
    # Either use bytecode, or have bqn specified.
    assert (bqn != null) == !useBytecode;

    stdenv.mkDerivation rec {
      pname = "cbqn" + lib.optionalString useBytecode "-bytecode";
      version = "unstable-2021-10-02";

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
