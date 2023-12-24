{ lib
, ajpy
, buildPythonPackage
, fetchPypi
, fetchpatch
, pythonAtLeast
, nose
, nose-exclude
, httplib2
, urllib3
, certifi
, six
}:
buildPythonPackage rec {
  pname = "httplib2shim";
  version = "0.0.3";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fGHa69k+15MN+d7U2/R/h9Najyk2PW45n7+f7JMPjRc=";
  };
  patches = [
    (fetchpatch {
      name = "fix-python-310-collections.patch";
      url = "https://patch-diff.githubusercontent.com/raw/GoogleCloudPlatform/httplib2shim/pull/16.patch";
      sha256 = "sha256-NjU8D2h2qS2QqgeDiMhqqUDbSqN4fGgb8BXQ93OYSaY=";
    })
  ];

  propagatedBuildInputs = [
    httplib2
    urllib3
    certifi
    six
  ];

  nativeCheckInputs = [
    nose
    nose-exclude
  ];

  checkPhase = ''
    runHook preCheck

    # fix test problems
    sed -i -e "s/httplib2._parse_www/httplib2.auth._parse_www/g" httplib2shim/test/httplib2_test.py
    sed -i -e "s/expected = b\"quR/expected = \"quR/" httplib2shim/test/httplib2_test.py

    # Exclude tests that:
    # - require network connection
    # - don't exist in httplib any more
    # - have changed significantly in httplib
    nosetests \
    --exclude="testGet(301ViaHttps|UnknownServer|ViaHttps|ViaHttpsSpecViolationOnLocation)" \
    --exclude="test(HeadRead|SniHostnameValidation|SslCertValidation)" \
    --exclude="testParseWWWAuthenticateMultiple\d?" \
    --exclude-test="httplib2shim.test.httplib2_test.UrlSafenameTest"

    runHook postCheck
  '';

  meta = with lib; {
    description = "urllib3 sanity for httplib2 users";
    homepage = "https://github.com/GoogleCloudPlatform/httplib2shim";
    license = licenses.mit;
    maintainers = with maintainers; [ jpts ];
  };
}
