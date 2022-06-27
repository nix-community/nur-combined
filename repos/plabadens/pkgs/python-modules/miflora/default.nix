{ lib
, buildPythonPackage
, fetchPypi

, bluepy
, pygatt
, btlewrap
}:

buildPythonPackage rec {
  pname = "miflora";
  version = "0.7.2";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "1df7a28b728af57b7cad4726e4b9d576f9e0652528d3b1f6c3ca1ca1066f7640";
  };

  propagatedBuildInputs =
    [ bluepy pygatt btlewrap ];

  doCheck = false;

  pythonImportsCheck = [ "miflora" ];

  meta = with lib; {
    description = "Library to read data from Mi Flora sensor";
    homepage = "https://github.com/basnijholt/miflora";
    license = licenses.mit;
  };

}
