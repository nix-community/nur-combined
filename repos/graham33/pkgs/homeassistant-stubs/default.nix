{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, homeassistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2023.8.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "068ixfcjqcl6fk868sja8xpwivlccvylw37bl6x2sr2zfb0yk05s";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    homeassistant
  ];

  pythonImportsCheck = [ "homeassistant-stubs" ];

  # no tests
  doCheck = false;

  preFixup = ''
    # Fix invalid syntax (https://github.com/python/mypy/issues/12441)
    find $out -name "*.pyi" -print0 | xargs -0 sed -i 's/, \*,/, *args,/g'
    find $out -name "*.pyi" -print0 | xargs -0 sed -i 's/, \*\*)/, **kwargs)/g'
  '';

  meta = with lib; {
    homepage = "https://github.com/KapJI/homeassistant-stubs";
    license = licenses.mit;
    description = "PEP 484 typing stubs for Home Assistant Core";
    maintainers = with maintainers; [ graham33 ];
  };
}
