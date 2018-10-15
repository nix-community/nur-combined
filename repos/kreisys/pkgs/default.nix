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

  nodejs-8_x  = let
    buildNodejs = pkgs.callPackage (pkgs.path + "/pkgs/development/web/nodejs/nodejs.nix") {};
  in buildNodejs {
    version = "8.12.0";
    sha256 = "16j1rrxkhmvpcw689ndw1raql1gz4jqn7n82z55zn63c05cgz7as";
  };

  nvim        = pkgs.callPackage ./nvim         { };
  oksh        = pkgs.callPackage ./ok.sh        { };
  webhook     = pkgs.callPackage ./webhook      { };
} // (pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
  # Linux only packages go here
  hydra = pkgs.hydra.overrideAttrs (_: {
    src    = pkgs.fetchFromGitHub {
      owner  = "kreisys";
      repo   = "hydra";
      rev    = "8391bc6d39e3de2b17fded6d84a6e6fa2465f195";
      sha256 = "0l0zmxydrpb7yqd3bcrdaiqwkq1bdrl5xn2bmm17kihvsrq9664g";
    };
  });
})
