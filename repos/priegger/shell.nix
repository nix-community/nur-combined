{ sources ? import ./nix/sources.nix
, pkgs ? import ./nix { inherit sources; }
}:
let
  pre-commit-hooks = import sources.pre-commit-hooks { inherit pkgs; };
in
pkgs.mkShell {
  name = "nur-packages";

  buildInputs = with pkgs; [
    cachix
    niv
    nixpkgs-fmt
  ];

  shellHook = pre-commit-hooks.shellHook {
    hooks = [ (pre-commit-hooks.hooks.mkNixpkgsFmt { nixpkgsFmtPkg = pkgs.nixpkgs-fmt; }) ];
  };
}
