{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "archive-hocr-tools";
  version = "1.1.59";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    rev = version;
    hash = "sha256-LVcABhEbbURKCZ4mP+MmE2Kw85BIXGp45XSBf83BV9g=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "hocr" ];

  meta = with lib; {
    description = "Efficient hOCR tooling";
    homepage = "https://github.com/internetarchive/archive-hocr-tools";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
