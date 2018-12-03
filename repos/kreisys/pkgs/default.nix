{ pkgs }:

let
  # Here mk stands for mark
  mkB0rked = pkgs.lib.addMetaAttrs { broken = true; };
  mkBashCli = pkgs.callPackage ./make-bash-cli.nix {};
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

  fishPlugins = pkgs.recurseIntoAttrs (pkgs.callPackages ./fish-plugins { });

  img2ansi = pkgs.callPackage ./img2ansi   { };
  krec2    = pkgs.callPackage ./krec2.nix  { inherit mkBashCli; };
  kretty   = pkgs.callPackage ./kretty.nix { inherit mkBashCli; };
  nvim     = pkgs.callPackage ./nvim       { };
  oksh     = pkgs.callPackage ./ok.sh      { };
  webhook  = pkgs.callPackage ./webhook    { };

  # Linux only packages go here
  hydra = pkgs.hydra.overrideAttrs (_: rec {
    name    = "hydra-${version}";
    version = "2018-10-15";
    patchs  = [ ./hydra-no-restricteval.diff ];
    src     = pkgs.fetchFromGitHub {
      owner   = "kreisys";
      repo    = "hydra";
      rev     = "e0f204f3da6245fbaf5cb9ef59568b775ddcb929";
      sha256  = "039s5j4dixf9xhrakxa349lwkfwd2l9sdds0j646k9w32659di61";
    };
  });
}
