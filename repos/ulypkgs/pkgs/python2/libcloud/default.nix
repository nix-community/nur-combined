{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy27,
  mock,
  pycrypto,
  requests,
  pytest-runner,
  pytest,
  requests-mock,
  typing,
  backports_ssl_match_hostname,
}:

buildPythonPackage (finalAttrs: {
  pname = "apache-libcloud";
  version = "2.8.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-cAlmkLJKeDLMWr39oZVLSf3cHAmjSKHmyqeBrIZ+1MY=";
  };

  checkInputs = [
    mock
    pytest
    pytest-runner
    requests-mock
  ];
  propagatedBuildInputs = [
    pycrypto
    requests
  ]
  ++ lib.optionals isPy27 [
    typing
    backports_ssl_match_hostname
  ];

  preConfigure = "cp libcloud/test/secrets.py-dist libcloud/test/secrets.py";

  # requires a certificates file
  doCheck = false;

  meta = with lib; {
    description = "A unified interface to many cloud providers";
    homepage = "https://libcloud.apache.org/";
    license = licenses.asl20;
  };

})
