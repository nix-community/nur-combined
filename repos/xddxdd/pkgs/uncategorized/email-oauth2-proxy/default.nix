{
  lib,
  sources,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  inherit (sources.email-oauth2-proxy) pname version src;
  pyproject = true;

  build-system = [ python3Packages.setuptools ];
  dependencies = [
    python3Packages.cryptography
    python3Packages.prompt-toolkit
    python3Packages.pyasyncore
    python3Packages.pyjwt
    # GUI dependencies
    python3Packages.packaging
    python3Packages.pillow
    python3Packages.pystray
    python3Packages.pywebview
    python3Packages.timeago
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
