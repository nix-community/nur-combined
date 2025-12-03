{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "tigerhash";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Kumokage";
    repo = "TigerHash";
    rev = "v${version}";
    hash = "sha256-yA2YXfVdM4wdDN1dHf5oVkjwVCWjos/krnm8HTsGA6s=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    cython
    wheel
  ];

  # fix: error: pytest-runner has been removed as it uses deprecated features of setuptools and is deprecated by upstream
  postPatch = ''
    substituteInPlace setup.py \
      --replace \
        "setup_requires=['pytest-runner']" \
        "setup_requires=[]"
  '';

  pythonImportsCheck = [
    "tigerhash"
  ];

  meta = {
    description = "Implementation of tiger hash in c++ with Python API";
    homepage = "https://github.com/Kumokage/TigerHash";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    # mainProgram = "tigerhash";
  };
}
