{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3Packages,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "email-oauth2-proxy";
  version = "2026-07-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonrob";
    repo = "email-oauth2-proxy";
    tag = finalAttrs.version;
    hash = "sha256-cvd7XgSn213aR4BqrdBoQed7i2m4MCkQBkLcO9uB+bo=";
  };
  dontCheckPythonMetadata = true;

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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/simonrob/email-oauth2-proxy/releases/tag/${finalAttrs.version}";
    mainProgram = "emailproxy";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "IMAP/POP/SMTP proxy that transparently adds OAuth 2.0 authentication for email clients";
    homepage = "https://github.com/simonrob/email-oauth2-proxy";
    license = with lib.licenses; [ asl20 ];
  };
})
