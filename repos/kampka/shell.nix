let
  pkgs = import <nixpkgs> {};

  nixpkgsFmt = (
    import (
      builtins.fetchTarball {
        url = "https://github.com/nix-community/nixpkgs-fmt/archive/v0.6.0.tar.gz";
        sha256 = "18kvsgl3kpla33dp1nbpd1kdgndfqcmlwwpjls55fp4mlczf8lcx";
      }
    ) {}
  );
  pre-commit = (import (builtins.fetchTarball "https://github.com/kampka/pre-commit-hooks/archive/master.tar.gz") {});

  hook = pre-commit.hooks.mkNixpkgsFmt { nixpkgsFmtPkg = nixpkgsFmt; };
  shellHook = pre-commit.shellHook { hooks = [ hook ]; };
in

pkgs.mkShell {
  name = "nix-packages";
  inherit shellHook;

  buildInputs = [
    nixpkgsFmt
  ];
}
