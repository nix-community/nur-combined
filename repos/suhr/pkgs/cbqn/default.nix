{ stdenv, lib, fetchFromGitHub, libffi, bootstrapped ? true, ripgrep }:

let
  libBQN = fetchFromGitHub {
    owner = "mlochbaum";
    repo = "bqn";
    rev = "1c18950453d3b4281c921fdb79f80fe4bec6ec3e";
    sha256 = "sha256-weGm0EkiwRp0XuRt8mZMX99TzhfS+5oUphvyzxKAqMc=";
  };

  bytecode = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "97bfb2e1d7858670c5f0d6d0e76d2718c29a8c16";
    sha256 = "sha256-zL8z9/FaPa6FF+t2Ht6jiWLXgN9ZSSo2a82hnimaEns=";
  };

  src = fetchFromGitHub {
    owner = "dzaima";
    repo = "cbqn";
    rev = "43b8b5e2a0616c45dec4e905cf5402e5d75b90c1";
    sha256 = "sha256-FWg3Gf+YY001xzfJqJIsBRvAMYK5ESrE0VgCHlGXzYQ=";
  };

  generic = { useBytecode ? false, bqn ? null, fullTestSuite ? true }:
    # Either use bytecode, or have bqn specified.
    assert (bqn != null) == !useBytecode;

    stdenv.mkDerivation rec {
      pname = "cbqn" + lib.optionalString useBytecode "-bytecode";
      version = "unstable-2022-06-24";

      inherit src;
      patches = lib.optional useBytecode ./generated.patch;
      buildInputs = [ libffi ];
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
