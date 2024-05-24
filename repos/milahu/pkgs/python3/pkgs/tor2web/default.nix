# FIXME tor2web is broken
# https://github.com/tor2web/Tor2web/pull/391

{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "tor2web";
  #version = "3.1.72"; # 2017-10-11
  #version = "3.2.0-unstable-2024-05-24";
  version = "3.2.0-broken-2024-05-24";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tor2web";
    repo = "Tor2web";
    #rev = "v${version}";
    # https://github.com/tor2web/Tor2web/pull/391
    rev = "7016e16a7d23da5d8695d79f2fd586c8c0459e5f";
    hash = "sha256-Cu4j8dcPGfHK3vFsRmEi57ttMKhroSUHnL/afhZ31oU=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    cffi
    cryptography
    enum34
    idna
    parsley
    pyasn1
    pycparser
    pyopenssl
    service-identity
    six
    transaction
    twisted
    zope-interface
    #legacy-cgi # TODO https://pypi.org/project/legacy-cgi/
  ];

  pythonImportsCheck = [ "tor2web" ];

  # install templates and example configs
  postInstall = ''
    mkdir -p $out/opt/tor2web
    cp -r data $out/opt/tor2web
  '';

  meta = with lib; {
    description = "HTTP proxy to access Tor Hidden Services with common web browsers";
    homepage = "https://github.com/tor2web/Tor2web";
    changelog = "https://github.com/tor2web/Tor2web/blob/${src.rev}/CHANGELOG";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "tor2web";
  };
}
