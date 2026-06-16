{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  flit-core,
  httpx,
  socksio,
  colorama,
  h2,
}:
buildPythonApplication rec {
  pname = "user-scanner";
  version = "1.3.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kaifcodec";
    repo = "user-scanner";
    rev = "refs/tags/v${version}";
    hash = "sha256-MyiBeKFilJpoelOmHn9dkYLWE6OV9Vkz0TORrQrSffA=";
  };

  build-system = [flit-core];

  dependencies = [
    httpx
    colorama
    socksio
    h2
  ];

  doCheck = false;

  # Remove auto-update and auto-prompt features
  postInstall = ''
    mkdir -p $out/lib/python*/site-packages/user_scanner
    echo '{"auto_update_status": false}' \
      > $out/lib/python*/site-packages/user_scanner/config.json
  '';

  meta = with lib; {
    description = "🕵️🫆 (2-in-1) Emaill and Username OSINT tool that analyzes username and email presence across multiple platforms, intended for security research, investigations, legitimate analysis";
    homepage = "https://github.com/kaifcodec/user-scanner";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [];
    mainProgram = "user-scanner";
  };
}
