{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pytest-mp";
  version = "2019-03-11";

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

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  propagatedBuildInputs = with python3Packages; [ pytest psutil ];

  doCheck = false;

  meta = with lib; {
    description = "A test batcher for multiprocessed Pytest runs";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
