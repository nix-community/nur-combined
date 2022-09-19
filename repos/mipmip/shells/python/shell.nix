# python.nix
with (import <nixpkgs> {});
let
  my-python-packages = python-packages: with python-packages; [
    setuptools
    requests
    boto3
    # other python packages you want
  ];
  python-with-my-packages = python3.withPackages my-python-packages;
in
mkShell {
  buildInputs = [
    python-with-my-packages
  ];
}

