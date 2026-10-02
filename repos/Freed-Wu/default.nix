# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  allPkgs = pkgs // myPkgs;
  callPackage =
    path: overrides:
    let
      f = import path;
    in
    f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  # nixpkgs' by-name layout: <root>/<first two letters>/<pname>/package.nix
  byNamePkgs =
    let
      dirs = [
        ./pkgs/by-name
        ./pkgs/development/tcl-modules/by-name
      ];
      subDirs =
        path:
        builtins.filter (name: (builtins.readDir path).${name} == "directory") (
          builtins.attrNames (builtins.readDir path)
        );
      packagePaths = pkgs.lib.concatMap (
        dir:
        pkgs.lib.concatMap (
          prefix: map (name: dir + "/${prefix}/${name}/package.nix") (subDirs (dir + "/${prefix}"))
        ) (subDirs dir)
      ) dirs;
    in
    builtins.listToAttrs (
      map (path: {
        name = baseNameOf (dirOf path);
        value = callPackage path { };
      }) packagePaths
    );

  myPkgs = {
    # The `lib`, `modules`, and `overlay` names are special
    lib = pkgs.lib // import ./lib { inherit pkgs; }; # functions
    modules = import ./modules; # NixOS modules
    overlays = import ./overlays; # nixpkgs overlays

    mySources = callPackage ./_sources/generated.nix { };

    gdb-prompt = callPackage ./pkgs/development/gdb-modules/gdb-prompt { };

    bash-prompt = callPackage ./pkgs/development/bash-modules/bash-prompt { };

    warna = callPackage ./pkgs/development/lua-modules/warna { };

    translate-shell = callPackage ./pkgs/development/python-modules/translate-shell { };
    mulimgviewer = callPackage ./pkgs/development/python-modules/mulimgviewer { };

    pyrime = callPackage ./pkgs/development/python-modules/pyrime { };
    lsp-tree-sitter = callPackage ./pkgs/development/python-modules/lsp-tree-sitter { };
    tree-sitter-muttrc = callPackage ./pkgs/development/python-modules/tree-sitter-muttrc { };
    mutt-language-server = callPackage ./pkgs/development/python-modules/mutt-language-server { };
    tree-sitter-tmux = callPackage ./pkgs/development/python-modules/tree-sitter-tmux { };
    tmux-language-server = callPackage ./pkgs/development/python-modules/tmux-language-server { };
    tree-sitter-zathurarc = callPackage ./pkgs/development/python-modules/tree-sitter-zathurarc { };
    zathura-language-server = callPackage ./pkgs/development/python-modules/zathura-language-server { };
    tree-sitter-requirements =
      callPackage ./pkgs/development/python-modules/tree-sitter-requirements
        { };
    requirements-language-server =
      callPackage ./pkgs/development/python-modules/requirements-language-server
        { };
    termux-language-server = callPackage ./pkgs/development/python-modules/termux-language-server { };

    sublime-syntax-language-server =
      callPackage ./pkgs/development/python-modules/sublime-syntax-language-server
        { };
  }
  // byNamePkgs;
in
myPkgs
