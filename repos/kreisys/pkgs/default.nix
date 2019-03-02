{ pkgs }:

let
  # Here mk stands for mark
  mkB0rked = pkgs.lib.addMetaAttrs { broken = true; };
  mkBashCli = pkgs.callPackage ./make-bash-cli {
    inherit (import ../lib { inherit pkgs; }) grid;
  };

in
{
  inherit (pkgs) consul dep2nix direnv exa ipfs;
  inherit (pkgs.gitAndTools) hub;

  buildkite-cli = pkgs.callPackage ./buildkite-cli { };
  consulate     = pkgs.callPackage ./consulate     { };

  fishPlugins = pkgs.recurseIntoAttrs (pkgs.callPackages ./fish-plugins { });

  hydra    = mkB0rked (pkgs.callPackage ./hydra {});
  img2ansi = pkgs.callPackage ./img2ansi   { };
  krec2    = pkgs.callPackage ./kreiscripts/krec2  { inherit mkBashCli; };
  kretty   = pkgs.callPackage ./kreiscripts/kretty { inherit mkBashCli; };
  kurl     = pkgs.callPackage ./kreiscripts/kurl   { inherit mkBashCli; };
  kraks    = pkgs.callPackage ./kreiscripts/kraks  { inherit mkBashCli; };
  nvim     = pkgs.callPackage ./nvim       { };
  oksh     = pkgs.callPackage ./ok.sh      { };
  webhook  = pkgs.callPackage ./webhook    { };
  vgo2nix  = pkgs.callPackage ./vgo2nix    { };
  xinomorf = (pkgs.callPackage ./xinomorf  { }).cli;
}
