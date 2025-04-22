{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "roman";
  version = "4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "roman";
    rev = version;
    hash = "sha256-H369RTtdnyaI1XH/DHe3v74gBlKjopNHUhna5wQuTlA=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "roman" ];

  meta = with lib; {
    description = "Integer to Roman numerals converter";
    homepage = "https://github.com/zopefoundation/roman";
    changelog = "https://github.com/zopefoundation/roman/blob/${src.rev}/CHANGES.rst";
    license = licenses.zpl21;
    maintainers = with maintainers; [ ];
  };
}
