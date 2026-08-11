{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ripemd";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "symbol";
    repo = "ripemd";
    rev = "v${version}";
    hash = "sha256-VGMYSvOpSXT6odCGyPg5L5dEfYuqrngknrWGPABSbJA=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "ripemd"
  ];

  meta = {
    description = "RIPEMD cryptographic hash functions in Python";
    homepage = "https://github.com/symbol/ripemd";
    # https://github.com/symbol/ripemd/blob/main/LICENSE.rst
    # TODO PublicDomain or BSD2
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = "ripemd";
  };
}
