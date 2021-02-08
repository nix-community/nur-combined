{ lib, stdenv, python3Packages, salt }:

python3Packages.buildPythonApplication rec {
  pname = "salt-lint";
  version = "0.4.1";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1h5wyn74glyiz377qwcg1y75l6mkh24bxjld4svifmx1v952fj2a";
  };

  buildInputs = with python3Packages; [ setuptools ];
  propagatedBuildInputs = [ salt python3Packages.pathspec ];

  meta = with lib; {
    homepage = "https://github.com/warpnet/salt-lint";
    description =
      "Checks Salt State files (SLS) for practices and behavior that could potentially be improved.";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.mit;
  };
}
