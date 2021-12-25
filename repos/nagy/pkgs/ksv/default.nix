{ config, lib, pkgs, bundlerApp, ... }:

bundlerApp {
  pname = "kaitai-struct-visualizer" ;
  gemdir = ./.;
  exes = ["ksv"];
}
