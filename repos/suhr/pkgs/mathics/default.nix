{ lib, pkgs, fetchFromGitHub
, pythonPackages
}:

pythonPackages.buildPythonApplication rec {
  name = "mathics-${version}";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "mathics";
    repo = "Mathics";
    rev = "c000869cef88371160937983c50fc486f514dc35";
    sha256 = "0n8qpksi7rw8s65ymwfs7s3klk7b8073fk0rgs2vma1bbn3rjdxn";
  };

  propagatedBuildInputs = with pythonPackages; [
    sympy django_1_8 mpmath dateutil colorama six
  ];

  doCheck = false;

  meta = {
    description = "A free, light-weight alternative to Mathematica";
    homepage = https://mathics.github.io/;
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
