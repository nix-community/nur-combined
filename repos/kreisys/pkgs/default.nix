{ pkgs, sources }:

let inherit (pkgs) lib newScope recurseIntoAttrs;

in lib.makeScope newScope (self:
  with self;
  let
    callPackages = lib.callPackagesWith (pkgs // self);
    emacsen = callPackages ./emacs { inherit sources; };
  in {
    inherit sources;

    mkBashCli = callPackage ./make-bash-cli {
      inherit (import ../lib { inherit pkgs; }) grid;
    };

    inherit (emacsen) emacs26 emacs27 emacs27-lucid emacsMacport;

    fishPlugins = recurseIntoAttrs (callPackages ./fish-plugins { });

    buildkite-cli = callPackage ./buildkite-cli { };
    consulate = callPackage ./consulate { };
    docker-auth = callPackage ./docker-auth { };
    docker-distribution = callPackage ./docker-distribution { };
    img2ansi = callPackage ./img2ansi { };
    image-to-ascii = callPackage ./image-to-ascii { };
    kraks = callPackage ./kreiscripts/kraks { };
    krec2 = callPackage ./kreiscripts/krec2 { };
    kretty = callPackage ./kreiscripts/kretty { };
    kurl = callPackage ./kreiscripts/kurl { };
    libfixposix = callPackage ./libfixposix { };
    nvim = callPackage ./nvim { };
    oksh = callPackage ./ok.sh { };
    pragmatapro = callPackage ./pragmatapro.nix { };
    silver = callPackage ./silver { };
    vgo2nix = callPackage ./vgo2nix { };
    webhook = callPackage ./webhook { };
  })
