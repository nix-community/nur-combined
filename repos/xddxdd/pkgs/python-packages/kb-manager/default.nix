{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  click,
  httpx,
  nix-update-script,
  pyyaml,
  tqdm,
  pathspec,
  requests,
  attrs,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "kb-manager";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dubh3124";
    repo = "OpenWebUI-KB-Manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qaMym8qnXwO3Fq8QPWUq7PZM1G57BGwtuqSbZQA2WCo=";
  };
  propagatedBuildInputs = [
    click
    httpx
    pyyaml
    tqdm
    pathspec
    requests
    attrs
    setuptools
  ];

  pythonImportsCheck = [ "kbmanager" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Command-line interface (CLI) tool for managing files and knowledge bases in OpenWebUI";
    homepage = "https://github.com/dubh3124/OpenWebUI-KB-Manager";
    changelog = "https://github.com/dubh3124/OpenWebUI-KB-Manager/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
  };
})
