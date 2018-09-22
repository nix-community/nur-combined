{ pkgs }:

let
  # Here mk stands for mark
  mkB0rked = pkgs.lib.addMetaAttrs { broken = true; };
in
{
  consul = pkgs.consul.overrideAttrs (_: {
    src    = pkgs.fetchFromGitHub {
      owner  = "hashicorp";
      repo   = "consul";
      rev    = "v1.1.0";
      sha256 = "0xm3gl8i7pgsbsc2397bwh9hp2dwnk4cmw5y05acqn3zpyp84sbv";
    };
  });

  consulate = pkgs.callPackage ./consulate { };

  fishPlugins = with pkgs; recurseIntoAttrs (callPackage ./fish-plugins { });

  img2ansi    = pkgs.callPackage ./img2ansi     { };
  nvim        = pkgs.callPackage ./nvim         { };
  oksh        = pkgs.callPackage ./ok.sh        { };
  webhook     = pkgs.callPackage ./webhook      { };
}

