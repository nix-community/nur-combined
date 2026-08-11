{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "werkzeug";
  version = "2.3.6";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pallets";
    repo = "werkzeug";
    rev = version;
    hash = "sha256-+7WJJbeoVSzhbHn4mkoxIMnu6IHyTjfbK/N167Zv1mU=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    markupsafe
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    watchdog = [
      watchdog
    ];
  };

  pythonImportsCheck = [ "werkzeug" ];

  meta = with lib; {
    description = "The comprehensive WSGI web application library";
    homepage = "https://github.com/pallets/werkzeug";
    changelog = "https://github.com/pallets/werkzeug/blob/${src.rev}/CHANGES.rst";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
