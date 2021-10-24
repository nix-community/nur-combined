{ lib, buildPythonPackage, fetchFromGitHub, poetry, flake8, setuptools }:
buildPythonPackage rec {
  pname = "flake8-broken-line";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "sobolevn";
    repo = pname;
    rev = "234de52b18e58b8dd32e210a6bdb197f7a260065";
    sha256 = "1qr552x2j7lgwnyk5vmyjiksg72pggmgk85wwdajic8as81lliqz";
  };

  format = "pyproject";
  nativeBuildInputs = [ poetry ];
  propagatedBuildInputs = [ flake8 setuptools ];

  meta = with lib; {
    description = "Flake8 plugin to forbid backslashes for line breaks";
    homepage = https://pypi.org/project/flake8-broken-line;
    license = licenses.mit;
  };
}

