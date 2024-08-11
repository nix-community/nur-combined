{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, wheel
, aiocache
, aiohttp
, pkce
, python-dateutil
, pytz
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "hydro-quebec-api-wrapper";
  version = "3.2.0";
  pyproject = true;

  src = fetchPypi {
    pname = "hydro_quebec_api_wrapper";
    inherit version;
    hash = "sha256-N/VCpsW435b7fASpaGLYdkklEuLJ0TOs60SVePEJ/hw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "setuptools==69.5.1" "setuptools"
    substituteInPlace pyproject.toml --replace-fail "setuptools_scm[toml]==8.1.0" "setuptools_scm[toml]"
    substituteInPlace pyproject.toml --replace-fail "wheel==0.43.0" "wheel"

    sed -i 's/setuptools[~=]/setuptools>/' pyproject.toml
    sed -i 's/wheel[~=]/wheel>/' pyproject.toml
  '';


  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = true; 
  dontCheckRuntimeDeps = true;

  dependencies = [
    aiocache
    #aiohttp
    pkce
    python-dateutil
    pytz
  ];

  pythonImportsCheck = [ "hydroqc" ];

  meta = with lib; {
    description = "A wrapper library to access hydro quebec API and more";
    homepage = "https://pypi.org/project/Hydro-Quebec-API-Wrapper/";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ ];
  };
}
