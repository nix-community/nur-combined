{ pkgs }:

let
  # Here mk stands for mark
  mkB0rked = pkgs.lib.addMetaAttrs { broken = true; };
in
{
  consulate = pkgs.callPackage ./consulate { };
  img2ansi = pkgs.callPackage ./img2ansi { };
  nvim = pkgs.callPackage ./nvim { };
  oksh = pkgs.callPackage ./ok.sh {  };
  webhook = pkgs.callPackage ./webhook { };
}

