{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  cryptography,
  prompt-toolkit,
  pyasyncore,
  pyjwt,
  setuptools,
  # GUI dependencies
  packaging,
  pillow,
  pystray,
  pywebview,
  timeago,
}:
buildPythonPackage rec {
  inherit (sources.email-oauth2-proxy) pname version src;
  pyproject = true;

  build-system = [ setuptools ];
  dependencies = [
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
