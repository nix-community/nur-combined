{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  filelock,
  requests,
  tqdm,
  urllib3,
}:
buildPythonPackage rec {
  pname = "modelscope-hub";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "modelscope_hub";
    tag = "v0.2.0";
    hash = "sha256-8q4Oz8WGVavrS1afolr8DYR7ATQSzssCgZpp+bdxbng=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    filelock
    requests
    tqdm
    urllib3
  ];

  pythonImportsCheck = [ "modelscope_hub" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/modelscope/modelscope_hub/releases/tag/${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Official Python client to connect with ModelScope Hub";
    homepage = "https://github.com/modelscope/modelscope_hub";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "ms";
  };
}
