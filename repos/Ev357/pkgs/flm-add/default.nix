{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "flm-add";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Atomic-Germ";
    repo = "flm-add";
    rev = "0dd96913f13acc2283da3ac90fe39e2fd77d12ba";
    sha256 = "sha256-rvZFe9/Dx1qSYekpkZY2oS5sMIsSTIAdzm8hyToJiX4=";
  };

  patches = [
    ./nixos.patch
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  meta = {
    description = "Utility to help with installing third-party FastFlowLM models";
    homepage = "https://github.com/Atomic-Germ/flm-add";
    license = lib.licenses.asl20;
    mainProgram = "flm-add";
  };
}
