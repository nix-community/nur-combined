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

  hub = pkgs.callPackage (pkgs.path + "/pkgs/applications/version-management/git-and-tools/hub") {
    Security = if pkgs.stdenv.isDarwin then pkgs.darwin.apple_sdk.frameworks.Security else null;
  };

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
}

