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
    hash = "sha256-cDjRt/ngWFvrPdjAqVbwK5WjRsC18kqejMA+utrwqnA=";
  };

  propagatedBuildInputs = [
    scipy
    pywavelets
    pillow
  ];

  doCheck = false;

  pythonImportsCheck = [ "imagehash" ];

  meta = {
    description = "Python Perceptual Image Hashing Module";
    homepage = "https://github.com/JohannesBuchner/imagehash";
    license = lib.licenses.bsd2;
  };
}
