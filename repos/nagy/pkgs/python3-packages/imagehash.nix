{
  lib,
  buildPythonPackage,
  fetchPypi,
  scipy,
  pywavelets,
  pillow,
}:

buildPythonPackage rec {
  pname = "imagehash";
  version = "4.3.1";
  format = "setuptools";

  src = fetchPypi {
    pname = "ImageHash";
    inherit version;
    sha256 = "sha256-cDjRt/ngWFvrPdjAqVbwK5WjRsC18kqejMA+utrwqnA=";
  };

  propagatedBuildInputs = [
    scipy
    pywavelets
    pillow
  ];

  doCheck = false;

  pythonImportsCheck = [ "imagehash" ];

  meta = with lib; {
    description = "Python Perceptual Image Hashing Module";
    homepage = "https://github.com/JohannesBuchner/imagehash";
    license = licenses.bsd2;
  };
}
