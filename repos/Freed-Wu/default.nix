# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  allPkgs = pkgs // myPkgs;
  callPackage = path: overrides:
    let f = import path;
    in f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);
  myPkgs = rec {
    # The `lib`, `modules`, and `overlay` names are special
    lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays

    mySources = callPackage ./_sources/generated.nix { };

    # https://github.com/NixOS/nixpkgs/pull/243429
    netease-cloud-music = callPackage ./pkgs/applications/audio/netease-cloud-music { };

    rime-kaomoji = callPackage ./pkgs/data/misc/rime-kaomoji { };
    gdb-prompt = callPackage ./pkgs/development/libraries/gdb-prompt { };
    tcl-prompt = callPackage ./pkgs/development/libraries/tcl-prompt { };
    bash-prompt = callPackage ./pkgs/shells/bash/bash-prompt { };
    undollar = callPackage ./pkgs/tools/misc/undollar { };
    manpager = callPackage ./pkgs/tools/misc/manpager { };
    jq-emojify = callPackage ./pkgs/tools/misc/jq-emojify { };
    tmux-rime = callPackage ./pkgs/tools/misc/tmux-rime { };

    lua-prompt-style = callPackage ./pkgs/development/lua-modules/prompt-style { };
    luajit-prompt-style = callPackage ./pkgs/development/lua-modules/prompt-style { luaPackages = pkgs.luajitPackages; };
    translate-shell = callPackage ./pkgs/development/python-modules/translate-shell { };
    mulimgviewer = callPackage ./pkgs/development/python-modules/mulimgviewer { };
    stardict-ecdict = callPackage ./pkgs/data/misc/stardict-ecdict { };
    stardict-jmdict-en-ja = callPackage ./pkgs/data/misc/stardict-jmdict-en-ja { };
    stardict-jmdict-ja-en = callPackage ./pkgs/data/misc/stardict-jmdict-ja-en { };
    stardict-langdao-ce-gb = callPackage ./pkgs/data/misc/stardict-langdao-ce-gb { };
    stardict-langdao-ec-gb = callPackage ./pkgs/data/misc/stardict-langdao-ec-gb { };
    windows10-themes = callPackage ./pkgs/data/misc/windows10-themes { };

    pyrime = callPackage ./pkgs/development/python-modules/pyrime { };
    lsp-tree-sitter = callPackage ./pkgs/development/python-modules/lsp-tree-sitter { };
    tree-sitter-muttrc = callPackage ./pkgs/development/python-modules/tree-sitter-muttrc { };
    mutt-language-server = callPackage ./pkgs/development/python-modules/mutt-language-server { };
    tree-sitter-tmux = callPackage ./pkgs/development/python-modules/tree-sitter-tmux { };
    tmux-language-server = callPackage ./pkgs/development/python-modules/tmux-language-server { };
    tree-sitter-zathurarc = callPackage ./pkgs/development/python-modules/tree-sitter-zathurarc { };
    zathura-language-server = callPackage ./pkgs/development/python-modules/zathura-language-server { };
    tree-sitter-make = callPackage ./pkgs/development/python-modules/tree-sitter-make { };
    tree-sitter-bash = callPackage ./pkgs/development/python-modules/tree-sitter-bash { };
    tree-sitter-requirements = callPackage ./pkgs/development/python-modules/tree-sitter-requirements { };
    requirements-language-server = callPackage ./pkgs/development/python-modules/requirements-language-server { };
    termux-language-server = callPackage ./pkgs/development/python-modules/termux-language-server { };
    autotools-language-server = callPackage ./pkgs/development/python-modules/autotools-language-server { };

    expect-language-server = callPackage ./pkgs/development/python-modules/expect-language-server { };
    sublime-syntax-language-server = callPackage ./pkgs/development/python-modules/sublime-syntax-language-server { };
    xilinx-language-server = callPackage ./pkgs/development/python-modules/xilinx-language-server { };
  };
in
myPkgs
