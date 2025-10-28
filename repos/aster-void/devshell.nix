{pkgs}:
pkgs.mkShell {
  packages = [
    pkgs.lefthook
    pkgs.nix-update

    # formatter
    pkgs.alejandra
    pkgs.prettier
  ];
  shellHook = ''
    lefthook install
  '';
}
