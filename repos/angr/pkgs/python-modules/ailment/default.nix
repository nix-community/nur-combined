{ buildPythonPackage
, fetchPypi
, isPy3k
, pyvex
, pkgs
}:

buildPythonPackage rec {
  pname = "ailment";
  version = "8.19.10.30";
  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "17a5r0011yz1pcn79pavrmzsk11dhq5biwcd025mh3ad6zhp272p";
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
