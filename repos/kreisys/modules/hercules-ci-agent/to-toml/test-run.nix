{ lib, runCommand, path, nix, ... }:

# To iterate:
# nix-instantiate --json --strict --readonly-mode --eval --expr 'with import <nixpkgs> {}; import ./to-toml.test.nix { src = ./to-toml.nix; inherit lib; }'

runCommand "to-toml-test-run" {
  NIX_PATH = "nixpkgs=${path}";
  nativeBuildInputs = [ nix ];
} ''
  export NIX_LOG_DIR=$PWD
  export NIX_STATE_DIR=$PWD
  nix-instantiate \
    --eval \
    --strict \
    --json \
    --option sandbox false \
    --readonly-mode \
    --expr "with (import <nixpkgs> {}); import ${./tests.nix} { src = ${./default.nix}; inherit lib; }" \
    > $out
  diff <(echo -n '{"failures":{}}') $out
''
