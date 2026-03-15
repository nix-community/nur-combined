{
  lib,
  fetchFromGitHub,
  python3Packages,
  binapy,
  jwskate,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "requests-oauth2client";
  version = "1.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "guillp";
    repo = "requests_oauth2client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ve4oBPz98fE+02BqDdlmVQPlM14DvfnknRM0TZCKxk4=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    attrs
    binapy
    furl
    jwskate
    requests
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
    pytest-examples
    pytest-freezer
    pytest-mock
    requests-mock
  ];

  meta = {
    description = "An OAuth2.x client based on `requests`";
    homepage = "https://github.com/guillp/requests-oauth2client";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
