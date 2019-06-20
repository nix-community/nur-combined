{ pkgs, lib, newScope, recurseIntoAttrs }:

lib.makeScope newScope (self: with self; let
  callPackages = lib.callPackagesWith (pkgs // self);
in {
  mkBashCli = callPackage ./make-bash-cli {
    inherit (import ../lib { inherit pkgs; }) grid;
  };

  buildkite-cli = callPackage ./buildkite-cli { };
  consulate     = callPackage ./consulate     { };
  emacs         = callPackage ./emacs         { };

  fishPlugins = recurseIntoAttrs (callPackages ./fish-plugins { });

  img2ansi = callPackage ./img2ansi   { };
  kraks    = callPackage ./kreiscripts/kraks  { };
  krec2    = callPackage ./kreiscripts/krec2  { };
  kretty   = callPackage ./kreiscripts/kretty { };
  kurl     = callPackage ./kreiscripts/kurl   { };
  lorri    = callPackage ./lorri      { };
  nvim     = callPackage ./nvim       { };
  oksh     = callPackage ./ok.sh      { };
  pragmatapro = callPackage ./pragmatapro.nix {};
  webhook  = callPackage ./webhook    { };
  vgo2nix  = callPackage ./vgo2nix    { };
  xinomorf = (callPackage ./xinomorf  { }).cli;
})
