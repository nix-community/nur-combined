{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, attrs
, iso8601
, httpx
, poetry
, pydantic
, pyjwt
, python-dateutil
, retrying
, rfc3339
, toml
  # Check Inputs
, pytestCheckHook
, pytest-asyncio
, respx
}:

buildPythonPackage rec {
  pname = "qcs-api-client";
  version = "0.20.5";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = "qcs-api-client-python";
    rev = "v${version}";
    sha256 = "sha256-M86swcogLDuJjlyFdYSAvaco3ebMAkM7DLuMm34G/T4=";
  };

  nativeBuildInputs = [ poetry ];

  # unpin max versions on packages
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "^" ">="
  '';

  propagatedBuildInputs = [
    attrs
    httpx
    iso8601
    pydantic
    pyjwt
    python-dateutil
    rfc3339
    retrying
    toml
  ];

  checkInputs = [
    pytestCheckHook
    pytest-asyncio
    respx
  ];
  pythonImportsCheck = [ "qcs_api_client" ];
  disabledTests = lib.optionals (lib.versionAtLeast respx.version "0.17.0") [
    "test_sync_client"  # don't seem to work on respx >= 0.17.0
  ];

  meta = with lib; {
    description = "A client library for accessing the Rigetti QCS API";
    homepage = "https://docs.rigetti.com/en/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
