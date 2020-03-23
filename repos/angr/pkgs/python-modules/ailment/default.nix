{ buildPythonPackage
, fetchPypi
, isPy3k
, pyvex
, pkgs
}:

buildPythonPackage rec {
  pname = "ailment";
  version = "8.20.1.7";
  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0lm6b8njl1a55i4m8mfkl42s1kmygzcgnxk8lvnczlcxbxq11h8z";
  };

  propagatedBuildInputs = [ pyvex ];

  # Tests require other angr related components.
  doCheck = false;

  meta = with pkgs.lib; {
    description = "The angr intermediate language";
    homepage = "https://github.com/angr/ailment";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
