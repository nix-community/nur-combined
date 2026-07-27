{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "briefcase";
  version = "0.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "beeware";
    repo = "briefcase";
    rev = "v${version}";
    hash = "sha256-dspMBBSrUoc0nK3GezSWlqs91vT2FNx6t8ibKxvxnqk=";
  };

  postPatch = ''
    sed -E -i 's/"setuptools(.*)==.*"/"setuptools\1"/' pyproject.toml
  '';

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [ setuptools setuptools-scm ];
  nativeBuildInputs = with python3.pkgs; [ setuptools setuptools-scm ];

  dependencies = with python3.pkgs; [
    binaryornot
    build
    chardet
    cookiecutter
    # dmgbuild
    gitpython
    httpx
    packaging
    pip
    platformdirs
    psutil
    python-dateutil
    rich
    setuptools
    tenacity
    tomli
    tomli-w
    truststore
    wheel
  ];

  pythonImportsCheck = [
    "briefcase"
  ];

  meta = {
    description = "Tools to support converting a Python project into a standalone native application";
    homepage = "https://github.com/beeware/briefcase";
    license = lib.licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    mainProgram = "briefcase";
  };
}
