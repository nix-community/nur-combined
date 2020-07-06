let
  sources = import ./nix;
  pkgs = sources.nixpkgs { };
  nixos-unstable = sources.pkgs-unstable { };
  nixos = sources.pkgs { };
in
pkgs.mkShell {
  name = "nix-config";
  buildInputs = with pkgs; [
    cachix
    # morph
    niv
    nixpkgs-fmt
  ];
  shellHook = ''
    export NIX_PATH="nixpkgs=${pkgs.path}:nixos=${nixos.path}:nixos-unstable=${nixos-unstable.path}"
  '';
}
