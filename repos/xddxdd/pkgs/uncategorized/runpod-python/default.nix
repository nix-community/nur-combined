{
  sources,
  lib,
  python3Packages,
  tqdm-loggable,
}:

python3Packages.buildPythonPackage {
  inherit (sources.runpod-python) pname version src;
  pyproject = true;

  prePatch = ''
    cat requirements.txt | cut -d' ' -f1 > requirements2.txt
    mv requirements2.txt requirements.txt
  '';

  propagatedBuildInputs = [
    python3Packages.aiohttp
    python3Packages.aiohttp-retry
    python3Packages.backoff
    python3Packages.boto3
    python3Packages.click
    python3Packages.colorama
    python3Packages.fastapi
    python3Packages.inquirerpy
    python3Packages.paramiko
    python3Packages.prettytable
    python3Packages.py-cpuinfo
    python3Packages.pynacl
    python3Packages.requests
    python3Packages.setuptools
    python3Packages.setuptools_scm
    python3Packages.tomli
    python3Packages.tomlkit
    python3Packages.urllib3
    python3Packages.uvicorn
    python3Packages.watchdog
    tqdm-loggable
  ];

  pythonImportsCheck = [ "runpod" ];

  meta = {
    description = "Python library for RunPod API and serverless worker SDK";
    homepage = "https://github.com/runpod/runpod-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "runpod";
  };
}
