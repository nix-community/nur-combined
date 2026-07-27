{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = [
    pkgs.lefthook
    pkgs.nix-update
    pkgs.deno

    # formatter
    pkgs.treefmt
    pkgs.alejandra
    pkgs.prettier
  ];
  shellHook = ''
    lefthook install
  '';
}
