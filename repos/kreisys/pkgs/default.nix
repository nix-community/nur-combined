{ pkgs, sources }:

let
  inherit (pkgs) lib newScope recurseIntoAttrs;

in
lib.makeScope newScope (self: with self; let
  callPackages = lib.callPackagesWith (pkgs // self);
  emacsen = callPackages ./emacs { inherit sources; };
in {
  mkBashCli = callPackage ./make-bash-cli {
    inherit (import ../lib { inherit pkgs; }) grid;
  };

  buildkite-cli = callPackage ./buildkite-cli { };
  consulate     = callPackage ./consulate     { };

  docker-auth         = callPackage ./docker-auth             { inherit sources; };
  docker-distribution = callPackage ./docker-distribution     { };

  inherit (emacsen) emacs26 emacs27 emacs27-lucid;

  fishPlugins = recurseIntoAttrs (callPackages ./fish-plugins { });

  img2ansi    = callPackage ./img2ansi           { };
  kraks       = callPackage ./kreiscripts/kraks  { };
  krec2       = callPackage ./kreiscripts/krec2  { };
  kretty      = callPackage ./kreiscripts/kretty { };
  kurl        = callPackage ./kreiscripts/kurl   { };
  libfixposix = callPackage ./libfixposix        { };
  lorri       = callPackage ./lorri              { };
  nvim        = callPackage ./nvim               { };
  oksh        = callPackage ./ok.sh              { };
  pragmatapro = callPackage ./pragmatapro.nix    { };
  webhook     = callPackage ./webhook            { };
  vgo2nix     = callPackage ./vgo2nix            { };
})
