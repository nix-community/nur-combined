with (import <nixpkgs> {});

mkShell {
  buildInputs = [
    nodejs
    yarn
    cypress
  ];
  shellHook = ''
  '';
}

