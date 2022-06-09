{ lib
, buildPythonPackage
, fetchFromGitHub
, sphinx-issues
, poetry
, openldap
, cyrus_sasl
, recommonmark
, sphinx
, sphinx_rtd_theme
, pytestCheckHook
, coverage
, pytest-cov
, tox
, mock
}:

buildPythonPackage rec {
  pname = "slapd";
  version = "0.1.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "python-ldap";
    repo = "python-slapd";
    rev = "${version}";
    sha256 = "sha256-hFnci+cHmy+E9d6JTBGTb1I3m2VRkAOSdtbhvz4ItqQ=";
  };

  nativeBuildInputs = [
    poetry
    openldap
    cyrus_sasl
  ];

  propagatedBuildInputs = [
    recommonmark
    sphinx
    sphinx_rtd_theme
    sphinx-issues
  ];

  checkInputs = [
    pytestCheckHook
    coverage
    pytest-cov
    tox
    mock
  ];

  preCheck = ''
    # Needed by tests to setup a mockup ldap server.
    export BIN="${openldap}/bin"
    export SBIN="${openldap}/bin"
    export SLAPD="${openldap}/libexec/slapd"
    export SCHEMA="${openldap}/etc/schema"
  '';

  pythonImportsCheck = [ "slapd" ];

  meta = with lib; {
    description = "Controls a slapd process in a pythonic way";
    homepage = "https://github.com/python-ldap/python-slapd";
    license = licenses.mit;
    maintainers = with maintainers; [ imsofi ];
  };
}
