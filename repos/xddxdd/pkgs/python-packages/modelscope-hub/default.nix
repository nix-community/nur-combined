{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  # Dependencies
  filelock,
  requests,
  tqdm,
  urllib3,
}:
buildPythonPackage rec {
  inherit (sources.modelscope-hub) pname version;
  pyproject = true;

  inherit (sources.modelscope-hub) src;

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    filelock
    requests
    tqdm
    urllib3
  ];

  pythonImportsCheck = [ "modelscope_hub" ];

  meta = {
    changelog = "https://github.com/modelscope/modelscope_hub/releases/tag/${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Official Python client to connect with ModelScope Hub";
    homepage = "https://github.com/modelscope/modelscope_hub";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "ms";
  };
}
