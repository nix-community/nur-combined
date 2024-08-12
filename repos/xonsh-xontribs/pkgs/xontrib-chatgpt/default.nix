{
  buildPythonPackage,
  lib,
  fetchFromGitHub,
  openai,
  setuptools,
  wheel,
}:
buildPythonPackage rec {
  pname = "xontrib-chatgpt";
  version = "0.2.3";
  src = fetchFromGitHub {
    owner = "drmikecrowe";
    repo = "xontrib-chatgpt";
    rev = "fdf6f7d13a8e6c354e3734cad0683215acd778c7";
    sha256 = "sha256-yfakSYP3ql3uKOaEwbUy9zP1Q6NUlhzkshLMGzthSOM=";
  };

  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
    openai
  ];

  propagatedBuildInputs = [
    openai
  ];

  meta = with lib; {
    homepage = "https://github.com/drmikecrowe/xontrib-chatgpt";
    description = "Gives the ability to use ChatGPT directly from the command line in the [xonsh shell](https://xon.sh).";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
  };
}
