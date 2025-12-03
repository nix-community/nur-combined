{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "make_playlist";
  version = "1.15.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "MatteoGuadrini";
    repo = "mkpl";
    rev = "v${version}";
    hash = "sha256-kb+tQYe6lzj+tD7tMyTA4Y7ECD24mq5CE1/KPCfL9V4=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    mutagen
    tempcache
  ];

  pythonImportsCheck = [
    "mkpl"
  ];

  meta = {
    description = "Make M3U format playlist from command line";
    homepage = "https://github.com/MatteoGuadrini/mkpl";
    changelog = "https://github.com/MatteoGuadrini/mkpl/blob/${src.rev}/CHANGES.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mkpl";
  };
}
