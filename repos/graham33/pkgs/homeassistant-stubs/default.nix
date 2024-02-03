{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, home-assistant
}:

buildPythonPackage rec {
  pname = "homeassistant-stubs";
  version = "2024.1.5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "KapJI";
    repo = pname;
    rev = "${version}";
    sha256 = "0iiqizgbpp2s629p01xprd8mjnqk2q9a6aghz8pb8w1ckjq4cbwr";
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
