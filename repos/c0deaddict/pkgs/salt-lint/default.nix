{ lib, stdenv, python3Packages, salt }:

python3Packages.buildPythonApplication rec {
  pname = "salt-lint";
  version = "0.5.2";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-BvRwp85vDbKlevAxXLJH3cGUPYiJ7/2QKMVgu0HMAEQ=";
  };

  buildInputs = with python3Packages; [ setuptools ];
  propagatedBuildInputs = [ salt ]
    ++ (with python3Packages; [ pathspec six future ]);

  meta = with lib; {
    homepage = "https://github.com/warpnet/salt-lint";
    description = "Checks Salt State files (SLS) for practices and behavior that could potentially be improved.";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.mit;
  };
}
