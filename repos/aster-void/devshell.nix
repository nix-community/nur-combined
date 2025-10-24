{pkgs}:
pkgs.mkShell {
  packages = [
    pkgs.lefthook

    # formatter
    pkgs.alejandra
    pkgs.prettier
  ];
  shellHook = ''
    lefthook install
  '';
}
