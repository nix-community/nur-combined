{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage rec {
  pname = "Yaml2ProbaTree";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Yaml2ProbaTree";
    rev = "f3566f4b26b0bcb43fff04a17b43074d5f952346";
    sha256 = "15vjpzw9jqv25vgc0kl7n3qci1mhm27ydnmlaa91vc5l4fg442jy";
  };

  propagatedBuildInputs = with python3Packages; [
    click
    pyyaml
  ];

  doCheck = false;

  meta = with lib; {
    description = "Converts a yaml structure to a LaTeX/TiKZ probability tree";
    homepage = "https://github.com/SCOTT-HAMILTON/Yaml2ProbaTree";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
