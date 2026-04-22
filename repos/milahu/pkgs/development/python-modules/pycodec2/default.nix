# based on https://github.com/NixOS/nixpkgs/pull/421656

{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  codec2,
  cython,
  numpy,
}:

buildPythonPackage rec {
  pname = "pycodec2";
  version = "3.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gregorias";
    repo = "pycodec2";
    rev = "ba67d50883ca7e8885618c741a9f80a9ac1d9a7f";
    hash = "sha256-gt/e2fmGffwlhSdUbg1ireCtQJ0xju+5u+QyttTZDog=";
  };

  postPatch = ''
    sed -i -E 's/([a-z0-9])(==|>=)[0-9*.]+(,<[0-9*.]+)?"/\1"/; s/"(=|==|>=|\^)[0-9*.]+(,<[0-9*.]+)?"/"*"/' pyproject.toml

    substituteInPlace pyproject.toml \
      --replace-fail \
        'requires-python = "*"' \
        'requires-python = ">=3.11"'
  '';

  build-system = [
    setuptools
    cython
    numpy
  ];

  dependencies = [
    codec2
    numpy
  ];

  meta = {
    description = "Cython wrapper for Codec 2";
    homepage = "https://github.com/gregorias/pycodec2";
    license = lib.licenses.bsd3;
  };
}
