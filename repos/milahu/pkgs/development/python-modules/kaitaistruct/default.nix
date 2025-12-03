{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchFromGitHub,
  brotli,
  lz4,
  setuptools,
}:

let
  kaitai_compress = fetchFromGitHub {
    owner = "kaitai-io";
    repo = "kaitai_compress";
    rev = "12f4cffb45d95b17033ee4f6679987656c6719cc";
    hash = "sha256-l3rGbblUgxO6Y7grlsMEiT3nRIgUZV1VqTyjIgIDtyA=";
  };
in
buildPythonPackage rec {
  pname = "kaitaistruct";
  # last tag: 0.10 @ 2022-07-07
  # https://github.com/kaitai-io/kaitai_struct_python_runtime/issues/81
  version = "0.11.2025.03.30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaitai-io";
    repo = "kaitai_struct_python_runtime";
    rev = "a6b0315bc1a07b5b54e2c086204e7633f780f0d7";
    hash = "sha256-3Ds9liv46YEgippA3L+i8fcTDgEfLs8RjfquRwRfqZ4=";
  };

  preBuild = ''
    ln -s ${kaitai_compress}/python/kaitai kaitai
    sed '32ipackages = kaitai/compress' -i setup.cfg
  '';

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    brotli
    lz4
  ];

  doCheck = false; # no tests in upstream

  pythonImportsCheck = [
    "kaitaistruct"
  ];

  meta = with lib; {
    description = "Kaitai Struct: runtime library for Python";
    homepage = "https://github.com/kaitai-io/kaitai_struct_python_runtime";
    license = licenses.mit;
    maintainers = [ ];
  };
}
