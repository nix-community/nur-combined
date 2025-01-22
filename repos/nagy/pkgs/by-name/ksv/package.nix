{ bundlerApp, ... }:

bundlerApp {
  pname = "kaitai-struct-visualizer";
  gemdir = ./.;
  exes = [ "ksv" ];
}
