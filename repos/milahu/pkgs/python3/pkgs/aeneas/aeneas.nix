{ lib
, python3
, fetchFromGitHub
, espeak-classic
}:

python3.pkgs.buildPythonApplication rec {
  pname = "aeneas";
  version = "1.7.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "readbeyond";
    repo = "aeneas";
    rev = "v${version}";
    hash = "sha256-rrh1ugzLWBNIxUOTXQhd5IepJNVpoe9mqMgIwidSqHE=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  buildInputs = [
    espeak-classic
  ];

  propagatedBuildInputs = with python3.pkgs; [
    beautifulsoup4
    lxml
    numpy
  ];

  pythonImportsCheck = [ "aeneas" ];

  # no effect
  /*
  # add runtime env. fix:
  # [WARN] The default input encoding is not UTF-8.
  # [WARN] You might want to set 'PYTHONIOENCODING=UTF-8' in your shell.
  makeWrapperArgs = [
    "--set-default" "PYTHONIOENCODING" "UTF-8"
  ];
  */

  meta = with lib; {
    description = "Aeneas is a Python/C library and a set of tools to automagically synchronize audio and text (aka forced alignment";
    homepage = "https://github.com/readbeyond/aeneas/";
    changelog = "https://github.com/readbeyond/aeneas/blob/${src.rev}/CHANGELOG";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
