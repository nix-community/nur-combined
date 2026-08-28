{
  lib,
  brotli,
  buildPythonPackage,
  certifi,
  python-dateutil,
  fetchpatch,
  fetchPypi,
  idna,
  mock,
  pysocks,
  pytest-freezegun,
  pytest-timeout,
  pytestCheckHook,
  tornado,
  trustme,
}:

buildPythonPackage (finalAttrs: {
  pname = "urllib3";
  version = "1.26.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-GRiPlpI4c8ksy5hxIOxKyqEvBGH6nOXT0HcryWWjngg=";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2021-28363.patch";
      url = "https://github.com/urllib3/urllib3/commit/8d65ea1ecf6e2cdc27d42124e587c1b83a3118b0.patch";
      hash = "sha256-OKk5Mm7MN3flyNtpXrkGADjrj4E5obtI2HGAG0LLENM=";
    })
  ];

  propagatedBuildInputs = [
    brotli
    certifi
    idna
    pysocks
  ];

  checkInputs = [
    python-dateutil
    mock
    pytest-freezegun
    pytest-timeout
    pytestCheckHook
    tornado
    trustme
  ];

  # Tests in urllib3 are mostly timeout-based instead of event-based and
  # are therefore inherently flaky. On your own machine, the tests will
  # typically build fine, but on a loaded cluster such as Hydra random
  # timeouts will occur.
  #
  # The urllib3 test suite has two different timeouts in their test suite
  # (see `test/__init__.py`):
  # - SHORT_TIMEOUT
  # - LONG_TIMEOUT
  # When CI is in the env, LONG_TIMEOUT will be significantly increased.
  # Still, failures can occur and for that reason tests are disabled.
  doCheck = false;

  preCheck = ''
    export CI # Increases LONG_TIMEOUT
  '';

  pythonImportsCheck = [ "urllib3" ];

  meta = with lib; {
    description = "Powerful, sanity-friendly HTTP client for Python";
    homepage = "https://github.com/shazow/urllib3";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
})
