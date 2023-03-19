{ npmlock2nix, testLib, runCommand, nodejs-16_x, nodejs-17_x, python3 }:
npmlock2nix.v2.node_modules {
  src = ./.;
}
