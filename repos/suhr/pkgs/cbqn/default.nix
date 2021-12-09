{ stdenv, lib, fetchFromGitHub, bootstrapped ? true, ripgrep }:

let
  libBQN = fetchFromGitHub {
    owner = "mlochbaum";
    repo = "bqn";
    rev = "40126f1df3998e30a47963c1aaaec4cea2003688";
    sha256 = "sha256-BnKTA0rjbQLlk9+jJ42YRpcYOZnpAT+7oCKGwZgveFs=";
  };

  bytecode = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "4a1fe17b15b1752da683a203170c19efe745319b";
    sha256 = "sha256-vh7i/z/GVk2wZVfiZcV9BQcySZmXQR9PbkaQsev7Vro=";
  };

  src = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "b9232a1f6843c254e16ba84458a53f190805740e";
    sha256 = "sha256-moLgf2e2csb1tAZqRGGuH6EF/qxHG/g2Ovf7+uRLgPI=";
  };

  generic = { useBytecode ? false, bqn ? null, fullTestSuite ? true }:
    # Either use bytecode, or have bqn specified.
    assert (bqn != null) == !useBytecode;

    stdenv.mkDerivation rec {
      pname = "cbqn" + lib.optionalString useBytecode "-bytecode";
      version = "unstable-2021-12-09";

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
