{
  fetchFromGitHub,
  lib,
  python3Packages,
  #setuptools,
  stdenv,
}:

python3Packages.buildPythonApplication rec {
  name = "vfio-isolate";
  version = "0.5.1.0";
  pyproject = true;
  #build-system = [ setuptools ];

  src = fetchFromGitHub {
    owner = "spheenik";
    repo = "vfio-isolate";
    rev = "c6eb01cab509dfa6a220dc17f44233fa4e93493c";
    hash = "sha256-NtvFi57A17Bv1kxhKuSbCPBlZlnW8ykg3+aQHeEZNp8=";
  };

  #dontCheckRuntimeDeps = true;
  buildInputs = with python3Packages; [
    pypaBuildHook
    pypaInstallHook
    pythonRelaxDepsHook
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    psutil
  ];

  meta = {
    description = "CPU and memory isolation for VFIO";
    homepage = "https://github.com/spheenik/vfio-isolate";
    license = lib.licenses.mit;
  };
}
