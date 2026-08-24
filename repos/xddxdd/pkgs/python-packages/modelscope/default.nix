{
  fetchFromGitHub,
  lib,
  buildPythonPackage,
  # Dependencies
  addict,
  attrs,
  datasets,
  einops,
  modelscope-hub,
  nix-update-script,
  oss2,
  pillow,
  python-dateutil,
  requests,
  scipy,
  setuptools,
  simplejson,
  sortedcontainers,
  tqdm,
  transformers,
  urllib3,
}:
buildPythonPackage (finalAttrs: {
  pname = "modelscope";
  version = "1.39.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelscope";
    repo = "modelscope";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jG0g7G2cXVNFUB1ItHcC0wJg6Zj0oGkKGLhgHji3sPQ=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    addict
    attrs
    datasets
    einops
    modelscope-hub
    oss2
    pillow
    python-dateutil
    requests
    scipy
    simplejson
    sortedcontainers
    tqdm
    transformers
    urllib3
  ];

  pythonImportsCheck = [ "modelscope" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/modelscope/modelscope/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Bring the notion of Model-as-a-Service to life";
    homepage = "https://www.modelscope.cn/";
    license = with lib.licenses; [ asl20 ];
    mainProgram = "modelscope";
  };
})
