{
  lib,
  buildPythonPackage,
  future,
  fetchFromGitHub,
  setuptools-scm,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "pefile";
  version = "2019.4.18";

  src = fetchFromGitHub {
    owner = "erocarrera";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-Sjd6S8K7224hlrKj9790neqwFVmgavFWkDZ6o0gGwTA=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    future
  ];

  # Test data encrypted
  doCheck = false;

  pythonImportsCheck = [ "pefile" ];

  meta = with lib; {
    description = "Multi-platform Python module to parse and work with Portable Executable (aka PE) files";
    homepage = "https://github.com/erocarrera/pefile";
    license = licenses.mit;
    maintainers = [ maintainers.pamplemousse ];
  };
}
