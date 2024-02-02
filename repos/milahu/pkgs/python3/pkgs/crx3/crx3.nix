{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "crx3";
  version = "0.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "liying2008";
    repo = "python-crx3";
    rev = "v${version}";
    hash = "sha256-2Ter3QU5MhD+adPk3VwAOqYan3E4H042c03cbS6FyPw=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    cryptography
    protobuf
  ];

  pythonImportsCheck = [ "crx3" ];

  meta = with lib; {
    description = "Chrome extension (crx) packaging & parsing library";
    homepage = "https://github.com/liying2008/python-crx3";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "crx3";
  };
}
