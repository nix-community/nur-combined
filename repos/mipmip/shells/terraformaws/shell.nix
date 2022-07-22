with (import <nixpkgs> {});

mkShell {
  buildInputs = [
    terraform
    awscli2
    pre-commit
  ];
  shellHook = ''
  '';
}

