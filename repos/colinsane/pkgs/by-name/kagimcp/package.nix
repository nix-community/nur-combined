{
  fetchFromGitHub,
  gitUpdater,
  kagiapi,
  lib,
  python3,
  stdenv,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "kagimcp";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "kagisearch";
    repo = "kagimcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I+lyGlw4/mH38DzuHRhKYyZz7I2bWKWJbIAT3sebm4g=";
  };

  nativeBuildInputs = [
    python3.pkgs.hatchling
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
    python3.pkgs.wrapPython
  ];

  propagatedBuildInputs = [
    kagiapi
    python3.pkgs.mcp
    python3.pkgs.pydantic
  ];

  postFixup = ''
    wrapPythonPrograms
  '';

  preInstallCheck = ''
    KAGI_API_KEY=dummy-for-test $out/bin/kagimcp -h | grep 'usage: kagimcp'
  '';

  doCheck = true;
  doInstallCheck = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    homepage = "https://github.com/kagisearch/kagimcp";
    description = "The Official Model Context Protocol (MCP) server for Kagi search & other tools";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
