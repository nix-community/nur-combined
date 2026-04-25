{
  sources,
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

buildPythonPackage rec {
  inherit (sources.runpod-python) pname version;
  pyproject = true;

  inherit (sources.runpod-python) src;

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

  meta = {
    changelog = "https://github.com/runpod/runpod-python/releases/tag/${version}";
    description = "Python library for RunPod API and serverless worker SDK";
    homepage = "https://github.com/runpod/runpod-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "runpod";
  };
}
