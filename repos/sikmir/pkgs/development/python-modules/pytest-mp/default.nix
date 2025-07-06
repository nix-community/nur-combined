{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage {
  pname = "pytest-mp";
  version = "2019-03-11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ansible";
    repo = "pytest-mp";
    rev = "49a8ff2ca9ef62d8c86854ab31d6b5d5d6cf3f28";
    hash = "sha256-KJEhMMQGrkLh5JJ6oGY0k2IZy+xobOF6dXP7Yc1CaQc=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "'setuptools-markdown'" ""

    # https://github.com/ansible/pytest-mp/issues/8
    substituteInPlace pytest_mp/terminal.py --replace-fail "reporter.writer" "reporter._tw"
  '';

  build-system = with python3Packages; [ setuptools ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  dependencies = with python3Packages; [
    pytest
    psutil
  ];

  doCheck = false;

  meta = {
    description = "A test batcher for multiprocessed Pytest runs";
    homepage = "https://github.com/ansible/pytest-mp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
