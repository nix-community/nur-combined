{ pkgs }:

let
  # Here mk stands for mark
  mkB0rked = pkgs.lib.addMetaAttrs { broken = true; };
  mkBashCli = pkgs.callPackage ./make-bash-cli.nix {
    inherit (import ../lib { inherit pkgs; }) grid;
  };

in
{
  consulate = pkgs.callPackage ./consulate { };

  fishPlugins = pkgs.recurseIntoAttrs (pkgs.callPackages ./fish-plugins { });

  hydra    = pkgs.callPackage ./hydra {};
  img2ansi = pkgs.callPackage ./img2ansi   { };
  krec2    = pkgs.callPackage ./krec2.nix  { inherit mkBashCli; };
  kretty   = pkgs.callPackage ./kretty     { inherit mkBashCli; };
  nvim     = pkgs.callPackage ./nvim       { };
  oksh     = pkgs.callPackage ./ok.sh      { };
  webhook  = pkgs.callPackage ./webhook    { };
  xinomorf = (pkgs.callPackage ./xinomorf  { }).cli;
}
