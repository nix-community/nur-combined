{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, home-assistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2023.11.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "0qcm9mx1r9z3h6f01mhfr5py3pwfzsfr64lmq6zg0hgrfqamzmdj";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    home-assistant
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
