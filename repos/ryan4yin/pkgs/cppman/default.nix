{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  groff,
}:
python3Packages.buildPythonApplication rec {
  pname = "cppman";
  version = "0.5.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "aitjcize";
    repo = "cppman";
    rev = "refs/tags/${version}";
    hash = "sha256-iPJR4XAjNrBhFHZVOATPi3WwTC1/Y6HK3qmKLqbaK98=";
  };

  nativeBuildInputs = [
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.distutils
  ];
  propagatedBuildInputs = [
    python3Packages.beautifulsoup4
    python3Packages.html5lib
    groff
  ];

  pythonImportsCheck = [ "cppman" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "C++ 98/11/14 manual pages for Linux/MacOS";
    homepage = "https://github.com/aitjcize/cppman";
    changelog = "https://github.com/aitjcize/cppman/blob/${src.rev}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lampros ];
    mainProgram = "cppman";
  };
}
