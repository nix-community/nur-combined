{ lib, python3, fetchFromGitHub }:

python3.pkgs.buildPythonApplication {
  pname = "oseasy-helper";
  version = "0-unstable-2026-10-15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "lihaoze123";
    repo = "oseasy-helper";
    rev = "c192c470806372109093bb6ae7c1bd3c5b5a8b22";
    hash = "sha256-ci+NkxcRo3p3ehiS3/rubZIFqe/M0WCY6s98UEauZX4=";
  };

  build-system = [ python3.pkgs.setuptools ];
  dependencies = [ python3.pkgs.psutil ];

  pythonImportsCheck = [ "oseasy_helper.cli" ];

  installCheckPhase = ''
    runHook preInstallCheck
    ${python3.interpreter} -m unittest discover -s tests -v
    "$out/bin/oseasy-helper" --help
    "$out/bin/oseasy-helper" client --help
    "$out/bin/oseasy-helper" student --help
    "$out/bin/oseasy-helper" video --help
    "$out/bin/oseasy-helper" control --help
    runHook postInstallCheck
  '';

  meta = {
    description = "CLI for OsEasy classroom video broadcasts and file reception";
    homepage = "https://github.com/lihaoze123/oseasy-helper";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "oseasy-helper";
  };
}
