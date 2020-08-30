{ buildPythonPackage
, fetchPypi
, isPy3k
, pyvex
, pkgs
}:

buildPythonPackage rec {
  pname = "ailment";
  version = "8.20.7.27";
  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "b2f9735b2fb210a8088e9fe95c0032b6b313553649b49608de54c1e5fc987c5c";
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
