{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: { inherit (import sources.niv { }) niv; })
    ];
  };
in
pkgs.mkShell {
  name = "nur-packages";

  buildInputs = with pkgs; [
    cachix
    niv
    nixpkgs-fmt
    shellcheck
  ];

  NIX_PATH = "nixpkgs=https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
}
