{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "yamlfixer";
  version = "0.9.15";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "opt-nc";
    repo = "yamlfixer";
    tag = finalAttrs.version;
    sha256 = "sha256-sZCQ60SP0nGke2Ia9MGJrQVBviQOO4aO8ne51tLJbHs=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    yamllint
  ];

  meta = with lib; {
    description = "Automates the fixing of problems reported by yamllint by parsing its output";
    mainProgram = "yamlfixer";
    license = licenses.gpl3Plus;
    homepage = "https://github.com/opt-nc/yamlfixer";
    maintainers = [ maintainers.wwmoraes ];
  };
})
