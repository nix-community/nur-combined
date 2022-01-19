{ lib, fetchPypi, python3Packages, setuptools, setuptools_scm}:

python3Packages.buildPythonPackage rec {
  pname = "convcolors";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1jbajh74bjmh383bw39zx91p2csl9k7l798blyv9hxnin4h5xmwb";
  };

  pythonImportsCheck = [ "convcolors" ];

  nativeBuildInputs = [ setuptools_scm ];

  propagatedBuildInputs = [ ];

  meta = with lib; {
    license = licenses.mit;
    platforms = platforms.unix;
    homepage = "https://github.com/CairX/convert-colors-py";
  };
}
