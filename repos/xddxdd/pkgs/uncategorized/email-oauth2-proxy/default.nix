{
  lib,
  sources,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  inherit (sources.email-oauth2-proxy) pname version;
  pyproject = true;

  inherit (sources.email-oauth2-proxy) src;

  build-system = [ python3Packages.setuptools ];
  dependencies = with python3Packages; [
    cryptography
    prompt-toolkit
    pyasyncore
    pyjwt
    # GUI dependencies
    packaging
    pillow
    pystray
    pywebview
    timeago
  ];

  pythonImportsCheck = [ "emailproxy" ];

  meta = {
    changelog = "https://github.com/simonrob/email-oauth2-proxy/releases/tag/${version}";
    mainProgram = "emailproxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "IMAP/POP/SMTP proxy that transparently adds OAuth 2.0 authentication for email clients";
    homepage = "https://github.com/simonrob/email-oauth2-proxy";
    license = with lib.licenses; [ asl20 ];
  };
}
