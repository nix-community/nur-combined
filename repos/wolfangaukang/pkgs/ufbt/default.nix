{ lib
, buildPythonApplication
, fetchFromGitHub
, setuptools
, setuptools-git-versioning
}:

buildPythonApplication rec {
  pname = "ufbt";
  version = "0.2.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "flipperdevices";
    repo = "flipperzero-ufbt";
    rev = "v${version}";
    hash = "sha256-gnSuwCRj8PFCuhEUP/B4YIjcLlY29527WWmjQQw7RkQ=";
  };

  propagatedBuildInputs = [
    setuptools
    setuptools-git-versioning
  ];

  meta = {
    description = "Compact tool for building and debugging applications for Flipper Zero (DOES NOT WORK ON NIXOS BECAUSE OF TOOLCHAIN)";
    homepage = "https://github.com/flipperdevices/flipperzero-ufbt";
    changelog = "https://github.com/flipperdevices/flipperzero-ufbt/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Only;
    mainProgram = "ufbt";
    maintainers = [ lib.maintainers.wolfangaukang ];
  };
}
