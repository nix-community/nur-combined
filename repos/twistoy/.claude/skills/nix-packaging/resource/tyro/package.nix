{ lib, buildPythonPackage, fetchFromGitHub, setuptools, docstring-parser
, typing-extensions, rich, shtab, typeguard, hatchling }:

buildPythonPackage rec {
  pname = "tyro";
  version = "0.9.9";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "brentyi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-iFKgnKd4606S/hEMHD7ZaTnGF16gmvbaE62nifw4o7c=";
  };

  build-system = [ hatchling ];

  dependencies = [ docstring-parser typing-extensions rich shtab typeguard ];

  pythonImportsCheck = [ "tyro" ];

  meta = with lib; {
    description = "tool for generating CLI interfaces in Python";
    homepage = "https://brentyi.github.io/tyro";
    license = licenses.mit;
  };
}
