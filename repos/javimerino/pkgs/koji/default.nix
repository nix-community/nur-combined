{ coreutils
, fetchFromGitHub
, fetchzip
, glibcLocales
, lib
, python3Packages
  #, rpm
, python-requests-gssapi
, system
, tzdata
}:

python3Packages.buildPythonApplication rec {
  pname = "koji";
  version = "1.34.0";
  src = fetchzip {
    url = "https://pagure.io/koji/archive/koji-${version}/koji-koji-${version}.tar.gz";
    hash = "sha256-pUAfg/wS8Wxzj9Udhr/R+QEQvQSdRr8yGFqbDR7pfT0=";
  };
  patches = [
    ./test_load_plugins-mock_expand_user.patch
    ./disable-test_instance.patch
  ];

  propagatedBuildInputs = with python3Packages; [
    dateutil
    psycopg2
    requests
    python-requests-gssapi
    rpm
    six
  ];

  preCheck = ''
    substituteInPlace tests/test_cli/test_import_sig.py --replace /bin/ls "${coreutils}/bin/ls"

    # The test harness tries to set the timezone, so it needs access to tzdata's zoneinfo
    export TZDIR=${tzdata}/share/zoneinfo
  '';
  postCheck = ''
    unset TZDIR
  '';

  checkInputs = (with python3Packages; [
    mock
    pytest
    requests-mock
  ]) ++ [
    glibcLocales
  ];
  setuptoolsCheckPhase = ''
    runHook preCheck

    # The only tests suites that are relevant for the cli we are building
    python3 setup.py test --test-suite tests.test_cli
    python3 setup.py test --test-suite tests.test_lib

    runHook postCheck
  '';

  meta = with lib; {
    description = "A flexible, secure, and reproducible way to build RPM-based software.";
    homepage = "https://pagure.io/koji/";
    maintainers = with maintainers; [ javimerino ];
    license = licenses.lgpl21Only;
  };
}
