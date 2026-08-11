{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
}:

# cannot be built as pythonApplication because the library functions are
# required for home-assistant
buildPythonPackage rec {
  pname = "speedtest-cli";
  version = "2.1.4";

  pyproject = true;

  # https://github.com/sivel/speedtest-cli/pull/800
  # Set secure connection as default
  # fix: ERROR: HTTP Error 403: Forbidden
  src = fetchFromGitHub {
    owner = "sivel";
    repo = "speedtest-cli";
    rev = "74d662e1e00de05779c71717626bb7ec299bdf3c";
    hash = "sha256-wv9TI8AFjHKkcav4InM7DG+PJfN25tMgLkmu+pw9lO0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  # tests require working internet connection
  doCheck = false;

  meta = with lib; {
    description = "Command line interface for testing internet bandwidth using speedtest.net";
    homepage = "https://github.com/sivel/speedtest-cli";
    license = licenses.asl20;
    maintainers = with maintainers; [ makefu domenkozar ];
  };
}
