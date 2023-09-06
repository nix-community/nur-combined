{ lib, fetchPypi, buildPythonPackage, setuptools-scm }:

buildPythonPackage rec {
  pname = "convcolors";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1jbajh74bjmh383bw39zx91p2csl9k7l798blyv9hxnin4h5xmwb";
  };

  pythonImportsCheck = [ "convcolors" ];

  nativeBuildInputs = [ setuptools-scm ];

  meta = with lib; {
    description =
      "Python package for converting colors between different color spaces";
    homepage = "https://pypi.org/project/convcolors/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
