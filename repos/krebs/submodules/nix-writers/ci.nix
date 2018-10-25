let
  pkgs = import <nixpkgs> {};

  hello_worlds = import examples/hello_world.nix;
  simples = import examples/simple.nix;

  writeTest = expectedValue: test: pkgs.writeScript "test" ''
    #!/bin/sh
    if test "$(${test})" != "${expectedValue}"; then
      echo 'test ${test} failed'
      exit 1
    fi
  '';

in
  pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair "hello_${n}" (writeTest "hello world" v)) hello_worlds //
  pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair "simple_${n}" v) {
    bash = writeTest "bash features" simples.bash;
    dash = writeTest "dash features" simples.dash;
    haskell = writeTest "Rolf" simples.haskell;
    js = writeTest "function add(n,d){return n+d}" simples.js;
    perl = writeTest "Howdy!" simples.perl;
    python2 = writeTest "['some', 'random', 'variables']" simples.python2;
    python3 = writeTest "['some', 'random', 'variables']" simples.python3;
    sed = writeTest "hello world" simples.sed;
  }

