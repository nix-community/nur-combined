{ buildPythonPackage
, fetchPypi
, isPy3k
, pyvex
, pkgs
}:

buildPythonPackage rec {
  pname = "ailment";
  version = "9.0.5405";
  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Y7QYctQjGpkxSEzt0Hokh89mmrVcJbwo+dtL29eWEc8=";
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
