{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  setuptools,
  flask,
  apscheduler,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "flask-apscheduler";
  version = "1.13.1";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "viniciuschiele";
    repo = "flask-apscheduler";
    tag = version;
    hash = "sha256-0gZueUuBBpKGWE6OCJiJL/EEIMqCVc3hgLKwIWFuSZI=";
  };

  pyproject = true;
  build-system = [
    setuptools
  ];

  pythonImportsCheck = [ "flask_apscheduler" ];

  dependencies = [
    flask
    apscheduler
    python-dateutil
  ];

  nativeCheckInputs = [
  ];

  meta = {
    description = "Adds APScheduler support to Flask";
    homepage = "https://github.com/viniciuschiele/flask-apscheduler";
    changelog = "https://github.com/viniciuschiele/flask-apscheduler/releases/tag/${version}";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
