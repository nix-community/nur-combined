{ lib, buildPythonPackage, fetchPypi, nose, hidapi }:

buildPythonPackage rec {
  pname = "hid";
  version = "1.0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1h9zi0kyicy3na1azfsgb57ywxa8p62bq146pb44ncvsyf1066zn";
  };

  propagatedBuildInputs = [ hidapi ];
  checkInputs = [ nose ];

  postPatch = ''
    substituteInPlace hid/__init__.py \
      --replace "LoadLibrary(lib)" \
                "LoadLibrary('${lib.getLib hidapi}/lib/' + lib)"
  '';

  meta = with lib; {
    homepage = "https://pypi.org/project/hid/";
    description = "ctypes bindings for hidapi";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
