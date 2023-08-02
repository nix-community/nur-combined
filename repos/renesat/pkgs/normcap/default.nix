{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "normcap";
  version = "0.4.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "dynobo";
    repo = "normcap";
    rev = "v${version}";
    hash = "sha256-dShtmoqS9TC3PHuwq24OEOhYfBHGhDCma8Du8QCkFuI=";
  };

  nativeBuildInputs = with python3.pkgs; [
    #pytestCheckHook
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyside6

    # Test
    toml
    pytest-qt
  ];

  postPatch = ''
    sed -i 's|PySide6-Essentials = "6.5.1"||' pyproject.toml
  '';

  # buildPhase = ''
  #   cd interfaces/daqp-python
  #   python setup.py bdist_wheel
  # '';

  meta = with lib; {
    description = "OCR powered screen-capture tool to capture information instead of images";
    homepage = "https://dynobo.github.io/normcap/";
    license = licenses.gpl3;
    maintainers = with maintainers; [renesat];
  };
}
