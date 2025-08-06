{
  lib,
  python,
  fetchFromGitLab,
  gmp,
  zlib,
}:
python.pkgs.buildPythonApplication rec {
  pname = "veripb";
  version = "2.3.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "MIAOresearch";
    repo = "VeriPB";
    rev = version;
    hash = "sha256-yJOr+dWG0mwu+FjZZol68axmrnVXrluRTHGVTGSsTB0=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "setuptools-git-versioning<2" "setuptools-git-versioning"
  '';

  build-system = [
    python.pkgs.setuptools
    python.pkgs.wheel
  ];

  propagatedBuildInputs = with python.pkgs; [
    cython
    pybind11
    setuptools-git-versioning
  ];

  buildInputs = [
    gmp
    zlib
  ];

  pythonImportsCheck = [ "veripb" ];

  meta = {
    description = "Proof checker for proof logging method using pseudo-Boolean reasoning for various combinatorial solving and optimization algorithms";
    homepage = "https://gitlab.com/MIAOresearch/VeriPB";
    changelog = "https://gitlab.com/MIAOresearch/VeriPB/-/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "veripb";
  };
}
