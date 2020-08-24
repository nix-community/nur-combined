let
  pkgs = import <nixpkgs> { };
  unstable = import <unstable> { };

  pre-commit = (import (builtins.fetchTarball "https://github.com/kampka/pre-commit-hooks/archive/master.tar.gz") { });

  hook = pre-commit.hooks.mkNixpkgsFmt { nixpkgsFmtPkg = unstable.nixpkgs-fmt; };
  shellHook = pre-commit.shellHook { hooks = [ hook ]; };
in
pkgs.mkShell {
  name = "nix-packages";
  inherit shellHook;

  buildInputs = [
    unstable.nixpkgs-fmt
  ];
}
