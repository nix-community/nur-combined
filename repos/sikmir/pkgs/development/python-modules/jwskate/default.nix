{
  lib,
  fetchFromGitHub,
  python3Packages,
  binapy,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "jwskate";
  version = "0.12.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "guillp";
    repo = "jwskate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yWsZb340Hwo63e6Ass7El8MJ4wK6uHODkghVdSFvu+U=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    binapy
    cryptography
    typing-extensions
  ];

  nativeCheckInputs = with python3Packages; [
    jwcrypto
    pytestCheckHook
    pytest-cov-stub
    pytest-freezer
  ];

  meta = {
    description = "A Pythonic implementation of the JOSE / JSON Web Crypto related RFCs (JWS, JWK, JWA, JWT, JWE)";
    homepage = "https://github.com/guillp/jwskate";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
