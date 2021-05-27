{ mkShell, nixpkgs-fmt, git }:

mkShell {
  name = "nur-devShell";

  buildInputs = [ nixpkgs-fmt git ];

  shellHook = ''
    ${git}/bin/git pull origin master
  '';
}
