{
  buildPythonPackage,
  autobean-refactor,
  pdm-pep517,
  fetchFromGitHub,
}:
buildPythonPackage rec {
  pname = "autobean-format";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "SEIAROTg";
    repo = "autobean-format";
    rev = "v${version}";
    hash = "sha256-ecB2biqKqBOay1xc4O36WsdyZkKdQcdb8cfMQKSP/A8=";
  };
  format = "pyproject";

  propagatedBuildInputs = [
    pdm-pep517
    autobean-refactor
  ];
}
