{pkgs, fetchFromGitHub}:
with pkgs.python3.pkgs;

buildPythonPackage rec {
  pname = "nixpkgs-pytools";
  version = "1.0.0-dev";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = pname;
    rev = "593443b5689333cad3b6fa5b42e96587df68b0f8";
    sha256 = "1cjpngr1rn5q59a1krgmpq2qm96wbiirc8yf1xmm21p3mskb2db4";
  };
  propagatedBuildInputs = [
    jinja2 setuptools
  ];
  checkInputs = [ black ];
}
