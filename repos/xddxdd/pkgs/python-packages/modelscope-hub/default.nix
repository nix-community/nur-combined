{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  cryptography,
  filelock,
  requests,
  tqdm,
  urllib3,
}:
buildPythonPackage (finalAttrs: {
  pname = "modelscope-hub";
  version = "0.4.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "modelscope_hub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+ylKonF4Q5wRY9vE1vcN+Hj202bfQrUy2coVrXiekdc=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    cryptography
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
