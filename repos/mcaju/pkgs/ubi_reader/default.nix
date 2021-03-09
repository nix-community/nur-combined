{ lib
, buildPythonApplication
, fetchPypi
, python-lzo }:

buildPythonApplication rec {
  pname = "ubi_reader";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;  
    sha256 = "16fdahjl29cq8izygl8b8r9lq4h4p2msba0dxda6826s7lq8llk8";
  };

  propagatedBuildInputs = [ python-lzo ];

  doCheck = false;

  meta = with lib; {
    description = "UBI Reader is a Python module and collection of scripts capable of extracting the contents of UBI and UBIFS images, along with analyzing these images to determine the parameter settings to recreate them using the mtd-utils tools.";
    homepage = "https://github.com/jrspruitt/ubi_reader";
    license = licenses.gpl3;
  };
}
