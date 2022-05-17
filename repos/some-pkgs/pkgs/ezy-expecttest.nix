{ lib
, buildPythonPackage
, fetchPypi
, poetry
}:

let
  pname = "ezy-expecttest";
  version = "0.1.3";
in
buildPythonPackage {
  inherit pname version;

  format = "pyproject";

  # PyPi because no versioning in the git repo
  src = fetchPypi {
    pname = "expecttest";
    inherit version;
    format = "setuptools";
    hash = "sha256-gwV2lYEdlBKK7RPtCUoHDbkOCpLqQAcfjuBzy6tXFJo=";
  };

  buildInputs = [
    poetry
  ];

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.mit;
    description = ''EZ Yang "golden" tests (testing against a reference implementation). Used by timm'';
    homepage = "https://github.com/rwightman/pytorch-image-models";
    platforms = lib.platforms.unix;
  };
}

