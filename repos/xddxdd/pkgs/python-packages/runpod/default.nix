{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  aiohttp,
  aiohttp-retry,
  backoff,
  boto3,
  click,
  colorama,
  fastapi,
  filelock,
  inquirerpy,
  nix-update-script,
  paramiko,
  prettytable,
  psutil,
  py-cpuinfo,
  pynacl,
  requests,
  setuptools,
  setuptools-scm,
  tomli,
  tomlkit,
  tqdm-loggable,
  urllib3,
  uvicorn,
  watchdog,
}:

buildPythonPackage (finalAttrs: {
  pname = "runpod";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpod-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/My9v1qW1chvD/Nup+u+EFZAvCJZhKfEjofYbn45Arw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  prePatch = ''
    cat requirements.txt | cut -d' ' -f1 > requirements2.txt
    mv requirements2.txt requirements.txt
  '';

  propagatedBuildInputs = [
    aiohttp
    aiohttp-retry
    backoff
    boto3
    click
    colorama
    fastapi
    filelock
    inquirerpy
    paramiko
    prettytable
    psutil
    py-cpuinfo
    pynacl
    requests
    setuptools
    setuptools-scm
    tomli
    tomlkit
    tqdm-loggable
    urllib3
    uvicorn
    watchdog
  ];

  pythonImportsCheck = [ "runpod" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/runpod/runpod-python/releases/tag/v${finalAttrs.version}";
    description = "Python library for RunPod API and serverless worker SDK";
    homepage = "https://github.com/runpod/runpod-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "runpod";
  };
})
