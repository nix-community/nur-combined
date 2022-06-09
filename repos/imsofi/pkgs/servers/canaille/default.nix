{ lib
, python3
, fetchFromGitLab
, extraPython3Packages
, openldap
, cyrus_sasl
}:

python3.pkgs.buildPythonApplication rec {
  pname = "canaille";
  version = "0.0.9";
  format = "pyproject";

  src = fetchFromGitLab {
    owner = "yaal";
    repo = "canaille";
    rev = "${version}";
    sha256 = "sha256-nJwA1kx082WSMxDcnMA2BnKaDoDLmf299q/6F8TuqWk=";
  };

  patches = [ ./0001-Use-poetry-standards-for-executables.patch ];

  nativeBuildInputs = with python3.pkgs; with extraPython3Packages; [
    poetry
    pytestCheckHook
    openldap
    cyrus_sasl
    coverage
    flask-webtest
    freezegun
    mock
    pyquery
    pytest-cov
    slapd
    smtpdfix
    sphinx
    sphinx_rtd_theme
    sphinx-issues
  ];

  propagatedBuildInputs = with python3.pkgs; with extraPython3Packages; [
    authlib1
    click
    email_validator
    flask
    flask-babel
    flask-themer
    flask_wtf
    ldap
    toml
    wtforms
    sentry-sdk
  ];

  preCheck = ''
    # Needed by tests to setup a mockup ldap server.
    export BIN="${openldap}/bin"
    export SBIN="${openldap}/bin"
    export SLAPD="${openldap}/libexec/slapd"
    export SCHEMA="${openldap}/etc/schema"
  '';

  postInstall = ''
    mkdir -p $out/etc/schema
    cp $out/lib/${python3.libPrefix}/site-packages/canaille/ldap_backend/schemas/* $out/etc/schema/
  '';

  meta = with lib; {
    description = "Simplistic OpenID Connect provider over OpenLDAP";
    homepage = "https://gitlab.com/yaal/canaille";
    license = licenses.mit;
    maintainers = with maintainers; [ imsofi ];
  };
}
