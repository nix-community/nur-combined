{ mkShell, nixpkgs-fmt, git }:

mkShell {
  name = "system-and-home-pull-on-entry";

  buildInputs = [ nixpkgs-fmt git ];

  shellHook = ''
    ${git}/bin/git pull origin master
  '';
}
