{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  scipy,
  pywavelets,
  pillow,
}:

buildPythonPackage rec {
  pname = "imagehash";
  version = "4.3.2";
  format = "setuptools";

  src = fetchPypi {
    pname = "ImageHash";
    inherit version;
    hash = "sha256-5Up5gFr7gqNKzeR0ahZUBQOpY2/R/7MdjgmbKbu/gVY=";
  };

  propagatedBuildInputs = [
    numpy
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
