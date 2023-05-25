{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "pytest-mp";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "ansible";
    repo = "pytest-mp";
    rev = version;
    hash = "sha256-+YttmCHFhUnKhLI8DFoI1juKN1YsxMi1vhf9KeJy+GM=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace "'setuptools-markdown'" ""
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
