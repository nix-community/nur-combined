{
  buildFHSEnv
, libsForQt5
, pkgs
, lib
, ...
}: let
  simulide-unwrapped = libsForQt5.callPackage ./unwrapped.nix {};
in buildFHSEnv {
  name      = "simulide";
  runScript = "simulide";
  targetPkgs = pkgs: with pkgs; [
    arduino-core-unwrapped
    simulide-unwrapped
  ];
  
  meta = with lib; {
    description = "Electronic Circuit Simulator (with batteries included)";
    homepage    = "https://code.launchpad.net/simulide";
    license     = licenses.gpl3;
  };
}
