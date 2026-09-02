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
buildPythonPackage (finalAttrs: {
  pname = "modelscope-hub";
  version = "0.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "modelscope_hub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M7i/5yMFZvdG5eiuxm75Wt3u5OjfwhvxCrhqpiW6tiA=";
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
    changelog = "https://github.com/modelscope/modelscope_hub/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Official Python client to connect with ModelScope Hub";
    homepage = "https://github.com/modelscope/modelscope_hub";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "ms";
  };
})
