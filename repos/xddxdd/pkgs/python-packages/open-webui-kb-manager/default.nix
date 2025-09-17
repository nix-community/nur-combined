{
  lib,
  sources,
  buildPythonPackage,
  # Dependencies
  click,
  httpx,
  pyyaml,
  tqdm,
  pathspec,
  requests,
  attrs,
  setuptools,
}:
buildPythonPackage rec {
  inherit (sources.open-webui-kb-manager) pname version src;
  pyproject = true;

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

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Command-line interface (CLI) tool for managing files and knowledge bases in OpenWebUI";
    homepage = "https://github.com/dubh3124/OpenWebUI-KB-Manager";
    changelog = "https://github.com/dubh3124/OpenWebUI-KB-Manager/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
  };
}
