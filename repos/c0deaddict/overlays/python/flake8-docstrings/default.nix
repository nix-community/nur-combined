{ stdenv, fetchFromGitLab, buildPythonPackage
, flake8, pydocstyle, pytest }:

buildPythonPackage rec {
  pname = "flake8-docstrings";
  version = "1.5.0";

  src = fetchFromGitLab {
    owner = "pycqa";
    repo = pname;
    rev = version;
    sha256 = "1si80si2snnsa1zbyf5d5lh8c66smb1anxa3dcys6l01ky5fkpqp";
  };

  propagatedBuildInputs = [ flake8 pydocstyle ];

  # There are no tests.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Extension for flake8 which uses pydocstyle to check docstrings.";
    homepage = "https://gitlab.com/pycqa/flake8-docstrings";
    maintainer = [ maintainers.c0deaddict ];
    license = licenses.mit;
  };
}
