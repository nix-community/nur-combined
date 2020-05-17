{ stdenv, python3Packages, salt }:

python3Packages.buildPythonApplication rec {
  pname = "salt-lint";
  version = "0.2.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "1c1qlkcx78w7pdis7qi7hldiy9lzasyy9f29zgrgd1fmdpqi3078";
  };

  buildInputs = with python3Packages; [ setuptools ];
  propagatedBuildInputs = [ salt python3Packages.pathspec ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/warpnet/salt-lint";
    description = "Checks Salt State files (SLS) for practices and behavior that could potentially be improved.";
    maintainers = with maintainers; [ c0deaddict ];
    license = licenses.mit;
  };
}
