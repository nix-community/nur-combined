{
  buildPythonPackage,
  lark,
  pdm-pep517,
  fetchFromGitHub,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "autobean-refactor";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "SEIAROTg";
    repo = "autobean-refactor";
    rev = "v${version}";
    hash = "sha256-oFUmmQQ/1dkyNQUPLUKQaiMQBFlxK55eTg5jC7CpfKs=";
  };

  format = "pyproject";

  propagatedBuildInputs = [
    lark
    pdm-pep517
    typing-extensions
  ];
}
